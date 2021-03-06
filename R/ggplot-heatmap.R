library(ggdendro)
library(ggplot2)
library(reshape)
library(grid)
 
## colours, generated by
## library(RColorBrewer)
## rev(brewer.pal(11,name="RdYlBu"))
my.colours <- c("#313695", "#4575B4", "#74ADD1", "#ABD9E9", "#E0F3F8", "#FFFFBF",
"#FEE090", "#FDAE61", "#F46D43", "#D73027", "#A50026")
 
mydplot <- function(ddata, row=!col, col=!row, labels=col) {
	## plot a dendrogram
	yrange <- range(ddata$segments$y)
	yd <- yrange[2] - yrange[1]
	nc <- max(nchar(as.character(ddata$labels$label)))
	tangle <- if(row) { 0 } else { 90 }
	tshow <- col
	p <- ggplot() +
		 geom_segment(data=segment(ddata), aes(x=x, y=y, xend=xend, yend=yend)) +
		 labs(x = NULL, y = NULL) + theme_dendro()
	if(row) {
		p <- p +
		scale_x_continuous(expand=c(0.5/length(ddata$labels$x),0)) +
		coord_flip()
	} else {
		p <- p +
		theme(axis.text.x = element_text(angle = 90, hjust = 1))
	}
	return(p)
}
 
g_legend<-function(a.gplot){
	## from
	## http://stackoverflow.com/questions/11883844/inserting-a-table-under-the-legend-in-a-ggplot2-histogram
	tmp <- ggplot_gtable(ggplot_build(a.gplot))
	leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
	legend <- tmp$grobs[[leg]]
	return(legend)
}
##' Display a ggheatmap
##'
##' this function sets up some viewports, and tries to plot the dendrograms to line up with the heatmap
##' @param L a list with 3 named plots: col, row, centre, generated by ggheatmap
##' @param col.width,row.width number between 0 and 1, fraction of the device devoted to the column or row-wise dendrogram. If 0, don't print the dendrogram
##' @return no return value, side effect of displaying plot in current device
##' @export
##' @author Chris Wallace
ggheatmap.show <- function(L, col.width=0.2, row.width=0.2) {
	grid.newpage()
	top.layout <- grid.layout(nrow = 2, ncol = 2,
	widths = unit(c(1-row.width,row.width), "null"),
	heights = unit(c(col.width,1-row.width), "null"))
	pushViewport(viewport(layout=top.layout))
	if(col.width>0)
		print(L$col, vp=viewport(layout.pos.col=1, layout.pos.row=1))
	if(row.width>0)
		print(L$row, vp=viewport(layout.pos.col=2, layout.pos.row=2))
	## print centre without legend
	print(L$centre +
		  theme(axis.line=element_blank(),
		  axis.text.x=element_blank(),axis.text.y=element_blank(),
		  axis.ticks=element_blank(),
		  axis.title.x=element_blank(),axis.title.y=element_blank(),
		  legend.position="none",
		  panel.background=element_blank(),
		  panel.border=element_blank(),panel.grid.major=element_blank(),
		  panel.grid.minor=element_blank(),plot.background=element_blank()),
		  vp=viewport(layout.pos.col=1, layout.pos.row=2))
	## add legend
	legend <- g_legend(L$centre)
	pushViewport(viewport(layout.pos.col=2, layout.pos.row=1))
	grid.draw(legend)
	upViewport(0)
}

##' Save a ggheatmap as a pdf
##'
##' this function is based HEAVILY on the ggheatmap.show function by the original author. It sets up the same pieces of the figure but then saves it as a pdf
##' @param L a list with 3 named plots: col, row, centre, generated by ggheatmap
##' @param filename a name for the resulting output; Default = 'plot.pdf'
##' @param page.width an integer, specifing inches of width of resulting output file; Default = 11
##' @param page.height an integer, specifing inches of height of resulting output file; Default = 8
##' @param col.width,row.width number between 0 and 1, fraction of the device devoted to the column or row-wise dendrogram. If 0, don't print the dendrogram
##' @return no return value, side effect of displaying plot in current device
##' @export
##' @author Lina L. Faller

ggheatmap.save <- function(L, filename, page.width, page.height, col.width=0.2, row.width=0.2) {
  
  # check if arguments have been specified, if not, use default values
  if ( missing( filename ) ) {
    filename = 'plot.pdf'
  } 
  if ( missing( page.width ) ) {
    page.width = 11
  } 
  if ( missing( page.height ) ) {
    page.height = 8
  } 
  
  pdf(filename, width = page.width, height = page.height)

  grid.newpage()
  top.layout <- grid.layout(nrow = 2, ncol = 2,
                            widths = unit(c(1-row.width,row.width), "null"),
                            heights = unit(c(col.width,1-row.width), "null"))
  pushViewport(viewport(layout=top.layout))
  if(col.width>0)
    print(L$col, vp=viewport(layout.pos.col=1, layout.pos.row=1))
  if(row.width>0)
    print(L$row, vp=viewport(layout.pos.col=2, layout.pos.row=2))
  ## print centre without legend
  print(L$centre +
          theme(axis.line=element_blank(),
                axis.text.x=element_blank(),axis.text.y=element_blank(),
                axis.ticks=element_blank(),
                axis.title.x=element_blank(),axis.title.y=element_blank(),
                legend.position="none",
                panel.background=element_blank(),
                panel.border=element_blank(),panel.grid.major=element_blank(),
                panel.grid.minor=element_blank(),plot.background=element_blank()),
        vp=viewport(layout.pos.col=1, layout.pos.row=2))
  ## add legend
  legend <- g_legend(L$centre)
  pushViewport(viewport(layout.pos.col=2, layout.pos.row=1))
  grid.draw(legend)
  upViewport(0)
  
  dev.off()
}

##' generate a heatmap + dendrograms, ggplot2 style
##'
##' @param x data matrix
##' @param hm.colours vector of colours (optional)
##' @return invisibly returns a list of ggplot2 objects. Display them with ggheatmap.show()
##' @author Chris Wallace
##' @export
##' @examples
##' ## test run
##' ## simulate data
##' library(mvtnorm)
##' sigma=matrix(0,10,10)
##' sigma[1:4,1:4] <- 0.6
##' sigma[6:10,6:10] <- 0.8
##' diag(sigma) <- 1
##' X <- rmvnorm(n=100,mean=rep(0,10),sigma=sigma)
##'  
##' ## make plot
##' p <- ggheatmap(X)
##'  
##' ## display plot
##' ggheatmap.show(p)
ggheatmap <- function(x,
	hm.colours=my.colours) {
	if(is.null(colnames(x)))
		colnames(x) <- sprintf("col%s",1:ncol(x))
	if(is.null(rownames(x)))
		rownames(x) <- sprintf("row%s",1:nrow(x))
	## plot a heatmap
	## x is an expression matrix
	row.hc <- hclust(dist(x), "ward")
	col.hc <- hclust(dist(t(x)), "ward")
	row.dendro <- dendro_data(as.dendrogram(row.hc),type="rectangle")
	col.dendro <- dendro_data(as.dendrogram(col.hc),type="rectangle")
 
	## dendro plots
	col.plot <- mydplot(col.dendro, col=TRUE, labels=TRUE) +
	scale_x_continuous(breaks = 1:ncol(x),labels=col.hc$labels[col.hc$order]) +
	theme(plot.margin = unit(c(0,0,0,0), "lines"))
	row.plot <- mydplot(row.dendro, row=TRUE, labels=FALSE) +
	theme(plot.margin = unit(rep(0, 4), "lines"))
 
	## order of the dendros
	col.ord <- match(col.dendro$labels$label, colnames(x))
	row.ord <- match(row.dendro$labels$label, rownames(x))
	xx <- x[row.ord,col.ord]
	dimnames(xx) <- NULL
	xx <- melt(xx)
 
	centre.plot <- ggplot(xx, aes(X2,X1)) + geom_tile(aes(fill=value), colour="white") +
	scale_fill_gradientn(colours = hm.colours) +
	labs(x = NULL, y = NULL) +
	scale_x_continuous(expand=c(0,0)) +
	scale_y_continuous(expand=c(0,0),breaks = NULL) +
	theme(plot.margin = unit(rep(0, 4), "lines"))
	ret <- list(col=col.plot,row=row.plot,centre=centre.plot)
	invisible(ret)
}
 