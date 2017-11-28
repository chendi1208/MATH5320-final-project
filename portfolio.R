file <- read.csv("test.csv", header = F)#
components_symbols <- as.vector(file$V1)#
initial_position <- as.numeric(file$V2)#
invest_date <- '2007-07-02'#
s0 <- sum(initial_position)

components0 <- getSymbols("AAPL", src = "google", env = NULL)
for (i in components_symbols) {
  components0 <- merge(components0, getSymbols(i, src = 'google', env = NULL))
}

components0 <-  data.frame(components0)
components <- data.frame(Date = row.names(components0), components0)
close_colnames <- colnames(components)
close_colnames <- close_colnames[grep("Close$", close_colnames)]
components <- components[, c("Date", close_colnames)]
colnames(components) <- c("Date", components_symbols)
components <- apply(components, 2, rev)
rownames(components) <- seq(1, dim(components)[1])
components <- data.frame(as.matrix(components), stringsAsFactors = F)

prices <- as.numeric(components[components$Date == invest_date,-1])
shares <- initial_position/prices
components$Portfolio <- apply(components, 1, function(o){sum(as.numeric(o)[-1]*shares)})
# components[components$Date == invest_date,]