
SurvCD <- function(X0, Y0, status, penalty=c("network", "mcp", "lasso"), lamb.1=NULL, lamb.2=NULL, clv=NULL, r=5,
                   init=NULL, alpha.i=1, robust=TRUE, standardize=TRUE, debugging=FALSE)
{
  intercept = TRUE
  status = as.numeric(status)
  if(is.null(clv)){
    clv = intercept*1
  }else{
    clv = setdiff(union(intercept, (clv+intercept)), 0)
  }

  n = nrow(X0); p.c = length(clv); p = ncol(X0)-p.c+intercept;
  V0 = apply(X0, 2, function(t) stats::sd(t)*sqrt((n-1)/n)); 
  if(any(V0==0) & (penalty == "network")) stop("X columns have standard deviation equal zero");
  if(standardize){
    V0[V0==0|is.na(V0)]=1
    X1 = scale(X0, center = TRUE, scale = V0)
  }
  if(intercept) X1 = cbind(Intercept = rep(1, n), X1)
  Y1 = Y0

  out = KMweight(X1, Y1, status, robust)
  X = out$X + 10^-9
  Y = out$Y
  init = match.arg(init, choices = c("zero","elnet","cox"))

  x.c=X[, clv, drop = FALSE]; x.g = X[, -clv, drop = FALSE]

  if(init == "zero"){
    b0 = rep(0, (p+p.c))
  } else if(init == "elnet"){
    b0 = initiation(X, Y, alpha.i)
  } else{
    b0 = initiation_cox(out$Xo, out$Yo, out$So)
  }

  a = Adjacency(x.g)
  method = substr(penalty, 1, 1)

  if(robust){
    b = RunSurv_robust(x.c, x.g, Y, lamb.1, lamb.2, b0[clv], b0[-clv], r, a, p, p.c, method, debugging)
  }else{
    triRowAbsSums = rowSums(abs(a*upper.tri(a, diag = FALSE)))
    b = RunSurv(x.c, x.g, Y, lamb.1, lamb.2, b0[clv], b0[-clv], r, a, triRowAbsSums, p, p.c, method)
  }

  b = as.numeric(b)
  vname = colnames(X0)
  if(!is.null(vname)){
    names(b) = c("Intercept", vname[clv], vname[-clv])
  }else if(p.c==1){
    names(b) = c("Intercept", paste("g", seq = (1:p), sep=""))
  }else{
    names(b) = c("Intercept", paste("clv", seq = (1:(p.c-1)), sep=""), paste("g", seq = (1:p), sep=""))
  }

  sub = which(utils::tail(b,p)!=0)
  out = list(b=b, Adj=a[sub,sub,drop=FALSE])
  # out
}

KMweight <- function(X1, Y1, status, robust){
  y.log <- log(Y1); inds = order(y.log)
  n = nrow(X1)
  xs=X1[inds,]
  d=status[inds]
  yy = y.log[inds]
  w <- numeric(n)
  w[1]=d[1]/n
  for ( i in 2:n ){
    tmp = 1
    for ( j in 1: (i-1) )
      tmp = tmp*((n-j)/(n-j+1))^d[j]
    w[i]=d[i]/(n-i+1)*tmp
  }
  if(robust){
    XZ = w * xs
    YZ = w * yy
  }else{
    XZ = sqrt(w) * xs
    YZ = sqrt(w) * yy
  }
  list(X = XZ, Y = YZ, Xo=xs, Yo=Y1[inds], So=d)
  # list(X = XZ, Y = YZ, So=d)
}
