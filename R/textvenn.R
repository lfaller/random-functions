##' Find setdiff()s and intersection of two vectors
##'
##' @title textvenn
##' @param A vector
##' @param B vector
##' @param quiet if FALSE (default) report to screen
##' @return invisibly returns a list containing items unique to A, the intersection, and items unique to B
##' @export
##' @author Chris Wallace
textvenn <- function(A,B,quiet=FALSE) {
  AnotB <- setdiff(A,B)
  AandB <- intersect(B,A)
  BnotA <- setdiff(B,A)
  if(!quiet) {
    cat("set A:\n")
    cat(AnotB,"\n")
    cat("intersection:\n")
    cat(AandB,"\n")
    cat("set B:\n")
    cat(BnotA,"\n")
  }
  invisible(list(A=AnotB,int=AandB,B=BnotA))
}
