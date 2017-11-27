bmsampset <- function(n, dt, k) {
  return(cbind(0, apply(sqrt(dt)*matrix(rnorm(k*n), nrow = k), 1, cumsum)))
}
