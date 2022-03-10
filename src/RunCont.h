#ifndef RUNCONT_h
#define RUNCONT_h

#include<RcppArmadillo.h>
// [[Rcpp::depends(RcppArmadillo)]]

using namespace Rcpp;
using namespace arma;

arma::vec RunCont(arma::mat const &xc, arma::mat const &xg, arma::vec const &y, double lamb1, double lamb2, arma::vec bc, arma::vec bg, double r, arma::mat const &a, arma::vec const &triRowAbsSums, int p, int pc, char method);

arma::vec RunCont_robust(arma::mat const &xc, arma::mat const &xg, arma::vec const &y, double lamb1, double lamb2, arma::vec bc0, arma::vec bg0, double r, arma::mat const &a, int p, int pc, char method, bool debugging);
					
#endif
