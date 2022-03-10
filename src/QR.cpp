#include<RcppArmadillo.h>
// [[Rcpp::depends(RcppArmadillo)]]
#include"QR.h"

using namespace Rcpp;
using namespace arma;


arma::vec QRWMR(arma::mat const &x, arma::vec const &y, arma::vec b)
{
  int p = x.n_cols, n = x.n_rows;
  arma::vec t = y - x * b;
  arma::vec u(n, fill::none), w(n, fill::none);
  arma::uvec index;
  
  for(int m = 0; m < p; m++){
    t += x.col(m) * b(m);
    u = t/x.col(m);
    w = arma::abs(x.col(m))/n;
    
    index = arma::sort_index(u);
    // arma::vec _w = w(index), _u = u(index);

    double TotalWeight = accu(w), SUM = 0;
    int j = 0;
    do{
      // SUM += _w(j)/TotalWeight;
	  SUM += w(index(j))/TotalWeight;
      j++;
    }while(SUM <= 0.5);
    // b(m) = _u(j-1);
	b(m) = u(index(j-1));
    t -= x.col(m) * b(m);
  }
  return(b);
}

void QRWMR(arma::mat const &x, arma::vec const &y, arma::vec &b, arma::mat const &w, arma::vec const &totalWeights)
{
  int p = x.n_cols, n = x.n_rows;
  arma::vec t = y - x * b;
  arma::vec u(n, fill::none);
  arma::uvec index;
  
  for(int m = 0; m < p; m++){
    t += x.col(m) * b(m);
    u = t/x.col(m);

    index = arma::sort_index(u);

	double SUM = 0;
    int j = 0;
    do{
	  SUM += w(index(j),m)/totalWeights(m);
      j++;
    }while(SUM <= 0.5);
	b(m) = u(index(j-1));
    t -= x.col(m) * b(m);
  }
}
