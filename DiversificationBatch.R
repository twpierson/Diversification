#You can use code you wrote for the correlation exercise here.

setwd("~/Desktop/UTK/Spring_2016/PhyloMeth/Diversification")
source("DiversificationFunctions.R")
tree <- read.tree("Eurycea_Tree")

# Make ultrametric.
tree <- chronos(tree, lambda=0)

# Add node labels.
makeNodeLabel(tree,method='number')

plot(tree)
nodelabels(tree$node.labels)

#First, let's look at a sister group comparison. Imagine you have one clade you think is especially noteworthy. 
focal.clade <- tips(tree,node=58)
ntax.focal.clade <- length(focal.clade)
sister.clade <- tips(tree,node=49)
ntax.sister.clade <- length(sister.clade)
depth.both <- findMRCA(tree,tips=c(focal.clade,sister.clade)) #time of the MRCA
actual.ratio <- min(c(ntax.focal.clade, ntax.sister.clade)) / max(c(ntax.focal.clade, ntax.sister.clade))

estimated.div.rate <- log(ntax.focal.clade + ntax.sister.clade)/depth.both #N(t) = N0 * exp(r*t)

nsim <- 10000
sim.ratios <- rep(NA, nsim)
for (i in sequence(nsim)) {
	left.clade <- sim.bd(b=estimated.div.rate, times=depth.both)[2,2] #get the number of taxa. We're assuming a pure birth model. This is dumb: if there's one thing we know about life, it's that extinction happens. But it's convenient for this case. This is known as a Yule model.
	right.clade <- sim.bd(b=estimated.div.rate, times=depth.both)[2,2] 
	sim.ratios[i] <- min(c(left.clade, right.clade)) / max(c(left.clade, right.clade))
	if(i%%500==0) {
		print(paste("Now", 100*i/nsim, "percent done"))	
	}
}

hist(sim.ratios, breaks=100, col="black", main=paste("Fraction of simulations with more disparity is", ecdf(sim.ratios)(actual.ratio)))
abline(v=actual.ratio, col="red")

#So, what does this mean about your observed result? What's the p-value?
# Well, the simulated results are really messy and don't follow the shape of a
# typical distribution. Probably because of my tree size. The p value would be 
# 0.5314.

#Now, try fitting different models for diversification.
div.results <- TryMultipleDivModels(tree)

best.model <- div.results[div.results[[5]]==0][[1]]

# What are the parameters of the best model? What do you think they mean?

# The best model was a Yule model, which has a single parameter (lambda)--
# the speciation rate. It's a 'pure birth' model.

# Now try running BAMM. Use the tutorial at http://bamm-project.org/quickstart.html to do diversification analyses.
