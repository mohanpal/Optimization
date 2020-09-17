# Sendit's Hub Problem

using JuMP, Gurobi, DelimitedFiles, Random, Plots
#---
# hub is the main function
# ncities = the number of cities
# factor is the reduction in cost factor when transporting between hubs
# snumber = the last four digits of your student number

function hub(ncities, factor, snumber)

 rng = MersenneTwister(7951)  #This will generate a unique set of data for each student
    cities=collect(1:ncities)   # This creates a set of cities {1,2,...,ncities}
    nhubs=2                    #This is the number of hubs

cost, quant=dc(ncities, factor, rng)   #function dc is given below
# This returns the transport costs and quantities

# The model should be given here

# Send values for printing
# printres(cities,nhubs, value.(hub),value.(flow))   #this function is given below
end  #function hub

#---   function dc
# Calculate the costs transporting through hubs
# This function calls functions 'locations' and 'distance'
function dc(n, factor,rng)
cities=collect(1:n)
cost=Array{Float64}(undef,(n,n,n,n))

loc=locations(rng,n,100,100)   #loc is a tuple of  (x,y) values
                         #representing locations of cities on 100x100 grid
dist=distance(loc)       #dist is a distance matrix
quant=rand(rng,0:2000,(n,n))  # Quantities of goods transported between two cities
for i in cities
quant[i,i]=0         # A city does not transport goods to itself
end

#This calculates the unit costs from i to j via k to l
for i in cities, j in cities, k in cities, l in cities
cost[i,j,k,l]= dist[i,k]+factor*dist[k,l]+dist[l,j]
end
#To keep a record of quantities, write the data to file "quant.txt"
open("hubdata.txt","w") do f
        writedlm(f,quant)
end
open("hubdata.txt","a") do f
        writedlm(f,dist)
end

return cost, quant   # Return the quantities and the calculated unit costs
end


#---
################### Locations ###############
#generate random n locations at (x,y)
################### Locations ###############
#generate random n locations at (x,y)
function locations(rng,n,xmax,ymax)
        loc=Tuple( (rand(rng,1:xmax),rand(rng,1:ymax)) for i=1:n)
        # Draw scatter plot
                x=Array{Float64}(undef,n)
                y=Array{Float64}(undef,n)
                for i=1:n
                        x[i]=loc[i][1]
                        y[i]=loc[i][2]
                end
          plotcities(x,y,n)
        return loc
end

#----
##########################
# This function calculates a symmetric distance matrix for a set of points (x,y)
# loc is a vector of tuples (x,y), see locations function
function distance(loc)
n=length(loc)   # No. of locations in loc
dist=zeros(Float64,(n,n))   #Initialise distance matrix with zeros
for i=1:n, j=i:n
        if i!=j
        dist[i,j]=sqrt((loc[i][1]-loc[j][1])^2+(loc[i][2]-loc[j][2])^2)
        dist[j,i]=dist[i,j]
        end #if
end   #i & j loop
return trunc.(dist,digits=1)
end
##########################
#----
function plotcities(x,y,n)
        p=scatter()    # It is necessary to define p outside of the for loop
        scatter(x,y,xlabel="X", ylabel="Y",leg=false)
        for i=1:n
        p=scatter!(;annotations=(x[i]+2,y[i],Plots.text("$i",10,:left) ))
        end  #end i loop
        display(p)
        savefig(p,"cities.png")
end  # end function


#---
function printres(cities,nhubs,hub,flow)
h=Array{Tuple{Vararg{Int}}}(undef,nhubs)
v=Array{Int64}(undef,nhubs)

# Find a vector containing only the two hub cities
j=1
for i in cities
 if hub[i]==1
          v[j]=i
          j+=1
  end
  if j>nhubs break end
end  # i loop

f=stdout   # stdout will print to the console
# open("res.txt","w") do r
println(f, "Hubs should be located at the following cities")
# will comprise cities that are hubs
for i in cities
if hub[i]==1
        print(f, i, ", ")
end #end if
end #i-loop
println(f); println(f)

for k in v
for l in v
        println(f," The following cities send goods via hub $k and $l ")
for i in cities
for j in cities
 if flow[i,j,k,l]==1
        print(f, i,", ")
  break   # j loop
  end  # if
end   #j loops
end  # i loop
println(f)
end   # l loop
end   # k loop
println(f)
println(f)
# end  #close print io
#
end  # function

#---
# hub(ncities, nhubs, factor)

#To run the model, enter last 4 digits of your
# student number in place of snumber
hub(12,0.5, snumber)
