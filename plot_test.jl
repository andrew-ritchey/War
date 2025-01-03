using Plots 
pyplot() # Switch to the pyplot backend. Needs to be installed first. 

p1 = plot(title = "Plot 1", reuse = false)
p2 = plot(title = "Plot 2", reuse = false)

function sx(E)
    a(x) = x^2 + E 
    b(x) = x + E 
    plot!(p1, a)
    plot!(p2, b)

end

E = [12
     24]


sx.(E) # More Julia way of doing your for loop

p1
p2