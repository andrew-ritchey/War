using Printf
using Random
using Base.Threads

ranks = Dict("2S"=>2, "3S"=>3, "4S"=>4, "5S"=>5, "6S"=>6, "7S"=>7, "8S"=>8, "9S"=>9, "10S"=>10, "JS"=>11, "QS"=>12, "KS"=>13, "AS"=>14,        
            "2H"=>2, "3H"=>3, "4H"=>4, "5H"=>5, "6H"=>6, "7H"=>7, "8H"=>8, "9H"=>9, "10H"=>10, "JH"=>11, "QH"=>12, "KH"=>13, "AH"=>14,
            "2C"=>2, "3C"=>3, "4C"=>4, "5C"=>5, "6C"=>6, "7C"=>7, "8C"=>8, "9C"=>9, "10C"=>10, "JC"=>11,  "QC"=>12, "KC"=>13, "AC"=>14,
            "2D"=>2, "3D"=>3, "4D"=>4, "5D"=>5, "6D"=>6, "7D"=>7, "8D"=>8, "9D"=>9, "10D"=>10, "JD"=>11,"QD"=>12, "KD"=>13, "AD"=>14,
            "JO"=>15)



function play(game)
    deck = collect(["2S", "3S", "4S", "5S", "6S", "7S", "8S", "9S", "10S", "JS", "QS", "KS", "AS",
                "2H", "3H", "4H", "5H", "6H", "7H", "8H", "9H", "10H", "JH", "QH", "KH", "AH",
                "2C", "3C", "4C", "5C", "6C", "7C", "8C", "9C", "10C", "JC", "QC", "KC", "AC",
                "2D", "3D", "4D", "5D", "6D", "7D", "8D", "9D", "10D", "JD", "QD", "KD", "AD",
                "JO", "JO"])

    shuffle!(deck)
    hand1 = Array{String}([])
    hand2 = Array{String}([])

    while length(deck) > 0
        push!(hand1, popfirst!(deck))
        push!(hand2, popfirst!(deck))
    end

    global count = 0

    start1 = sum([ranks[card] for card in hand1])
    start2 = sum([ranks[card] for card in hand2])

    while length(hand1) > 0 && length(hand2) > 0
        global count += 1
        if count > 10000
            break
        end

        global strength1 = sum([ranks[card] for card in hand1])
        global strength2 = sum([ranks[card] for card in hand2])

        # @printf "Hand 1 (%d, %d): %s\n" length(hand1) strength1 hand1  
        # @printf "Hand 2 (%d, %d): %s\n\n" length(hand2) strength2 hand2
        # sleep(1)

        card1 = popfirst!(hand1)
        card2 = popfirst!(hand2)
        # @printf "Card 1: %s     Card 2: %s\n" card1 card2

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
            # @printf "WAR!\n"
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
            # @printf "Card 1: %s     Card 2: %s\n" card1 card2

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
                # @printf "Pushing card %s to Hand 1\n" card
                push!(hand1, card)
            end
        else
            for card in cat(bank1, bank2, dims=(1, 1))
                # @printf "Pushing card %s to Hand 2\n" card
                push!(hand2, card)
            end
        end
    end

    @printf "\nGame %d Statistics:\n" game
    if count == 10001
        @printf "Draw\n"
    elseif  length(hand1) > length(hand2)
        @printf "Winner: Hand 1!\n"
    else
        @printf "Winner: Hand 2!\n"
    end

    @printf "Rounds: %d\n" count
    @printf "Hand 1 Starting Strength: %d\n" start1
    @printf "Hand 2 Starting Strength: %d\n" start2
end

number_of_games = 1000
# a = zeros(number_of_games)

for i in range(1, number_of_games)
    # a[i] = Threads.threadid()
    play(i)
end
