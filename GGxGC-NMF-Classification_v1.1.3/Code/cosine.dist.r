cosine.dist <- function(x) 
{ 
x <- as.matrix(x) 
ss <- 1/sqrt(colSums(x^2)) 
col.similarity <- t(x) %*% x *outer(ss, ss) 
colnames(col.similarity) <- rownames(col.similarity) <- colnames(x) 
return(col.similarity) 
} 