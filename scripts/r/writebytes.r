library(ggplot2)
library(reshape)

args <- commandArgs(TRUE)
minX <- as.integer(args[1])
maxX <- as.integer(args[2])

source(paste(Sys.getenv('R_SCRIPTS_PATH'), 'annotation.r', sep='/'))
df3 <- load_annotations()

if(file.exists("writebytes_reduced.txt")){
	df <- read.table("writebytes_reduced.txt", header = TRUE, check.names = FALSE)
	df <- melt(df, id="time")
	df$type <- 'Process'
	
	if(file.exists("writebytes_node_reduced.txt")){
		df2 <- read.table("writebytes_node_reduced.txt", header = TRUE, check.names = FALSE)
		df2 <- melt(df2, id="time")
		df2$type <- 'Node'
		
		df <- rbind(df, df2)
	}
	
	p <- ggplot(df) + theme_bw()
	p <- add_annotations(p, df3)
	p <- p + geom_line(alpha = 0.8, aes(time, value, group=variable, colour=variable))
	
	if(file.exists("writebytes_node_reduced.txt")){
		p <- p + facet_grid(type ~ ., scales = "free_y")
	}
	
	p <- p + theme(legend.position = "none")
	p <- p + labs(x = "\nTime into experiment (Seconds)", y = "Write_bytes per process (KiBytes/s)\n")
	if(length(args) > 0){
		p <- p + xlim(minX, maxX)
	}
	p
	
	ggsave(file="writebytes.png", width=12, height=6, dpi=100)
}

if(file.exists("wchars_reduced.txt")){
	df <- read.table("wchars_reduced.txt", header = TRUE, check.names = FALSE)
	df <- melt(df, id="time")
	df$type <- 'Process'
	
	if(file.exists("wchars_node_reduced.txt")){
		df2 <- read.table("wchars_node_reduced.txt", header = TRUE, check.names = FALSE)
		df2 <- melt(df2, id="time")
		df2$type <- 'Node'
		
		df <- rbind(df, df2)
	}
	
	p <- ggplot(df) + theme_bw()
	p <- add_annotations(p, df3)
	p <- p + geom_line(alpha = 0.8, aes(time, value, group=variable, colour=variable))
	
	if(file.exists("wchars_node_reduced.txt")){
		p <- p + facet_grid(type ~ ., scales = "free_y")
	}
	
	p <- p + theme(legend.position = "none")
	p <- p + labs(x = "\nTime into experiment (Seconds)", y = "WChar per process (KiBytes/s)\n")
	if(length(args) > 0){
		p <- p + xlim(minX, maxX)
	}
	p
	
	ggsave(file="wchars.png", width=12, height=6, dpi=100)
}