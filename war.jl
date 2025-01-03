using Base.Threads
using Random
using Plots
using StatsPlots
using Statistics

ranks = Dict("2S"=>2, "3S"=>3, "4S"=>4, "5S"=>5, "6S"=>6, "7S"=>7, "8S"=>8, "9S"=>9, "10S"=>10, "JS"=>11, "QS"=>12, "KS"=>13, "AS"=>14,        
            "2H"=>2, "3H"=>3, "4H"=>4, "5H"=>5, "6H"=>6, "7H"=>7, "8H"=>8, "9H"=>9, "10H"=>10, "JH"=>11, "QH"=>12, "KH"=>13, "AH"=>14,
            "2C"=>2, "3C"=>3, "4C"=>4, "5C"=>5, "6C"=>6, "7C"=>7, "8C"=>8, "9C"=>9, "10C"=>10, "JC"=>11,  "QC"=>12, "KC"=>13, "AC"=>14,
            "2D"=>2, "3D"=>3, "4D"=>4, "5D"=>5, "6D"=>6, "7D"=>7, "8D"=>8, "9D"=>9, "10D"=>10, "JD"=>11,"QD"=>12, "KD"=>13, "AD"=>14,
            "JO"=>15)

# Function to shuffle the deck in a thread-safe way
function shuffle_deck(deck)
    rng = MersenneTwister()  # Create a new random number generator
    return shuffle(rng, deck)
end

function play_war(deck, num_games)
    decks = Vector{Vector{String}}(undef, num_games)
    results =  Vector{Vector{Float64}}(undef, num_games)
    @threads for i in 1:num_games        
        decks[i] = shuffle_deck(deck)

        max_strength = sum([ranks[card] for card in decks[i]])
        hand1 = decks[i][1:2:end]
        hand2 = decks[i][2:2:end]

        start_hand1 = sum([ranks[card] for card in hand1])
        start_hand2 = sum([ranks[card] for card in hand2])
        n_turns = 3600

        for j in 1:3600
            card1 = popfirst!(hand1)
            card2 = popfirst!(hand2)

            rank1 = ranks[card1]
            rank2 = ranks[card2]

            bank1 = Array{String}([])
            bank2 = Array{String}([])
    
            if rank1 == 2 && rank2 == 15
                rank2 = -1
            end
    
            if rank2 == 2 && rank1 == 15
                rank1 = -1
            end
    
            while rank1 == rank2
                push!(bank1, card1)
                push!(bank2, card2)
    
                if length(hand1) < 4 || length(hand2) < 4
                    break
                end
    
                for i in 1:3
                    push!(bank1, popfirst!(hand1))
                    push!(bank2, popfirst!(hand2))
                end
    
                card1 = popfirst!(hand1)
                card2 = popfirst!(hand2)
    
                rank1 = ranks[card1]
                rank2 = ranks[card2]
            end
    
            if card1 ∉ bank1
                push!(bank1, card1)
            end
    
            if card2 ∉ bank2
                push!(bank2, card2)
            end
    
            if rank1 > rank2
                for card in cat(bank1, bank2, dims=(1, 1))
                    push!(hand1, card)
                end
            else
                for card in cat(bank1, bank2, dims=(1, 1))
                    push!(hand2, card)
                end
            end

            if length(hand1) == 0 || length(hand2) == 0
                n_turns = j
                break
            end
        end
        results[i] = collect([start_hand1/max_strength, 
                              start_hand2/max_strength, 
                              n_turns/3600, 
                              length(hand1)/54, 
                              length(hand2)/54])
    end

    return results
end

# Example usage
deck = collect(["2S", "3S", "4S", "5S", "6S", "7S", "8S", "9S", "10S", "JS", "QS", "KS", "AS",
                "2H", "3H", "4H", "5H", "6H", "7H", "8H", "9H", "10H", "JH", "QH", "KH", "AH",
                "2C", "3C", "4C", "5C", "6C", "7C", "8C", "9C", "10C", "JC", "QC", "KC", "AC",
                "2D", "3D", "4D", "5D", "6D", "7D", "8D", "9D", "10D", "JD", "QD", "KD", "AD",
                "JO", "JO"])

results = play_war(deck, 100000)

transposed_data = [getindex.(results, i) for i in 1:5]

# Create the whisker plot
violin(transposed_data, 
        title="War Statistics", 
        ylabel="Values", 
        xticks=(1:5, ["Hand 1 Strength", "Hand 2 Strength", 
                      "Turns to Finish", 
                      "Hand 1 Wins", "Hand 2 Wins"]),
        legend=false)
savefig("war_ouput.png")
