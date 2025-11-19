void update_final(double * x, double * y, int vecsize, int iters)
{
    int i, j;

   for(j=0;j<iters;j++){
    for(i=0;i<vecsize;i++) {
      x[i]=x[i]+y[i];
    } 
   }
}

