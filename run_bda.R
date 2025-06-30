
R version 4.5.1 (2025-06-13) -- "Great Square Root"
Copyright (C) 2025 The R Foundation for Statistical Computing
Platform: x86_64-redhat-linux-gnu

R is free software and comes with ABSOLUTELY NO WARRANTY.
You are welcome to redistribute it under certain conditions.
Type 'license()' or 'licence()' for distribution details.

  Natural language support but running in an English locale

R is a collaborative project with many contributors.
Type 'contributors()' for more information and
'citation()' on how to cite R or R packages in publications.

Type 'demo()' for some demos, 'help()' for on-line help, or
'help.start()' for an HTML browser interface to help.
Type 'q()' to quit R.

> setwd('/run/media/mcarmo/662229CC2229A253/RProjects/ggmbsl/')
> # Project start
+ library(BDgraph)
+ library(qgraph)
+ library(pROC)
> Type 'citation("pROC")' for a citation.

Attaching package: ‘pROC’

The following objects are masked from ‘package:BDgraph’:

    auc, roc

The following objects are masked from ‘package:stats’:

    cov, smooth, var

> > . + > p <- c(10, 25, 50, 100)
> dgp_rho <- c(2 / (p[1] - 1), 0.5)     # Sparse vs. Dense
+ dgp_b <- c(3, p[1])              # Diffuse vs. Strict
> # Define the "Prior" parameters for model fitting
+ model_g <- c(2 / (p[1] - 1), 0.5)
+ model_b <- c(3, p[1])
> conditions_grid <- expand.grid(
+   p = rep(p, each=3),
+   n = NA,
+   true_g = NA,
+   prior_g = NA,
+   #true_rho = dgp_rho, # sparsity prior
+   #prior_g = model_g,
+   true_b = dgp_b,
+   prior_b = model_b,
+   graph_type = c("scale-free", "random", "cluster")
+   )
> conditions_grid$n  <- conditions_grid$p * c(1,2,5)
> # Define the true edge probabilities
+ row_indices3 <- rep(which(conditions_grid$graph_type == "random"), each = 3)
+ expanded_grid3 <- conditions_grid[row_indices3, ]
> prob_vector <- unlist(lapply(conditions_grid$p, function(p_val) {
+   # The vector of two probability values to be created for each p
+   c( 0.8, 0.5, 2 / (p_val - 1)) } ) )
> conditions_grid <- rbind(conditions_grid[conditions_grid$graph_type != 'random',], expanded_grid3)
+ conditions_grid$true_g <- ifelse(conditions_grid$graph_type == "random", prob_vector, NA)
> # Define the misspecified prior edge probabilities
+ row_indices2 <- rep(which(conditions_grid$graph_type == "random"), each = 3)
+ expanded_grid2 <- conditions_grid[row_indices2, ]
> conditions_grid <- rbind(conditions_grid[conditions_grid$graph_type != 'random',], expanded_grid2)
+ conditions_grid$prior_g <- ifelse(conditions_grid$graph_type == "random", prob_vector, NA)
> # Define the number of clusters
+ conditions_grid$clusters <- ifelse(conditions_grid$graph_type == "cluster",
+                                    pmax(2, floor(conditions_grid$p/10)), NA)
> # Fixing the row names
+ rownames(conditions_grid) <- seq(nrow(conditions_grid))
> reps <- 5 # Number of simulation repetitions
+ mcmc_iter <- 5000
+ burnin <- 2000
+ num_chains <- 4 # Number of chains for convergence diagnostics
> results_df <- data.frame()
> conditions_grid <- rbind(conditions_grid[conditions_grid$graph_type != 'random',], expanded_grid3)
Error in rbind(deparse.level, ...) : 
  numbers of columns of arguments do not match
> conditions_grid <- rbind(conditions_grid[conditions_grid$graph_type != 'random',], expanded_grid3)
Error in rbind(deparse.level, ...) : 
  numbers of columns of arguments do not match
> conditions_grid
      p   n     true_g    prior_g true_b prior_b graph_type clusters
1    10  10         NA         NA      3       3 scale-free       NA
2    10  20         NA         NA      3       3 scale-free       NA
3    10  50         NA         NA      3       3 scale-free       NA
4    25  25         NA         NA      3       3 scale-free       NA
5    25  50         NA         NA      3       3 scale-free       NA
6    25 125         NA         NA      3       3 scale-free       NA
7    50  50         NA         NA      3       3 scale-free       NA
8    50 100         NA         NA      3       3 scale-free       NA
9    50 250         NA         NA      3       3 scale-free       NA
10  100 100         NA         NA      3       3 scale-free       NA
11  100 200         NA         NA      3       3 scale-free       NA
12  100 500         NA         NA      3       3 scale-free       NA
13   10  10         NA         NA     10       3 scale-free       NA
14   10  20         NA         NA     10       3 scale-free       NA
15   10  50         NA         NA     10       3 scale-free       NA
16   25  25         NA         NA     10       3 scale-free       NA
17   25  50         NA         NA     10       3 scale-free       NA
18   25 125         NA         NA     10       3 scale-free       NA
19   50  50         NA         NA     10       3 scale-free       NA
20   50 100         NA         NA     10       3 scale-free       NA
21   50 250         NA         NA     10       3 scale-free       NA
22  100 100         NA         NA     10       3 scale-free       NA
23  100 200         NA         NA     10       3 scale-free       NA
24  100 500         NA         NA     10       3 scale-free       NA
25   10  10         NA         NA      3      10 scale-free       NA
26   10  20         NA         NA      3      10 scale-free       NA
27   10  50         NA         NA      3      10 scale-free       NA
28   25  25         NA         NA      3      10 scale-free       NA
29   25  50         NA         NA      3      10 scale-free       NA
30   25 125         NA         NA      3      10 scale-free       NA
31   50  50         NA         NA      3      10 scale-free       NA
32   50 100         NA         NA      3      10 scale-free       NA
33   50 250         NA         NA      3      10 scale-free       NA
34  100 100         NA         NA      3      10 scale-free       NA
35  100 200         NA         NA      3      10 scale-free       NA
36  100 500         NA         NA      3      10 scale-free       NA
37   10  10         NA         NA     10      10 scale-free       NA
38   10  20         NA         NA     10      10 scale-free       NA
39   10  50         NA         NA     10      10 scale-free       NA
40   25  25         NA         NA     10      10 scale-free       NA
41   25  50         NA         NA     10      10 scale-free       NA
42   25 125         NA         NA     10      10 scale-free       NA
43   50  50         NA         NA     10      10 scale-free       NA
44   50 100         NA         NA     10      10 scale-free       NA
45   50 250         NA         NA     10      10 scale-free       NA
46  100 100         NA         NA     10      10 scale-free       NA
47  100 200         NA         NA     10      10 scale-free       NA
48  100 500         NA         NA     10      10 scale-free       NA
49   10  10         NA         NA      3       3    cluster        2
50   10  20         NA         NA      3       3    cluster        2
51   10  50         NA         NA      3       3    cluster        2
52   25  25         NA         NA      3       3    cluster        2
53   25  50         NA         NA      3       3    cluster        2
54   25 125         NA         NA      3       3    cluster        2
55   50  50         NA         NA      3       3    cluster        5
56   50 100         NA         NA      3       3    cluster        5
57   50 250         NA         NA      3       3    cluster        5
58  100 100         NA         NA      3       3    cluster       10
59  100 200         NA         NA      3       3    cluster       10
60  100 500         NA         NA      3       3    cluster       10
61   10  10         NA         NA     10       3    cluster        2
62   10  20         NA         NA     10       3    cluster        2
63   10  50         NA         NA     10       3    cluster        2
64   25  25         NA         NA     10       3    cluster        2
65   25  50         NA         NA     10       3    cluster        2
66   25 125         NA         NA     10       3    cluster        2
67   50  50         NA         NA     10       3    cluster        5
68   50 100         NA         NA     10       3    cluster        5
69   50 250         NA         NA     10       3    cluster        5
70  100 100         NA         NA     10       3    cluster       10
71  100 200         NA         NA     10       3    cluster       10
72  100 500         NA         NA     10       3    cluster       10
73   10  10         NA         NA      3      10    cluster        2
74   10  20         NA         NA      3      10    cluster        2
75   10  50         NA         NA      3      10    cluster        2
76   25  25         NA         NA      3      10    cluster        2
77   25  50         NA         NA      3      10    cluster        2
78   25 125         NA         NA      3      10    cluster        2
79   50  50         NA         NA      3      10    cluster        5
80   50 100         NA         NA      3      10    cluster        5
81   50 250         NA         NA      3      10    cluster        5
82  100 100         NA         NA      3      10    cluster       10
83  100 200         NA         NA      3      10    cluster       10
84  100 500         NA         NA      3      10    cluster       10
85   10  10         NA         NA     10      10    cluster        2
86   10  20         NA         NA     10      10    cluster        2
87   10  50         NA         NA     10      10    cluster        2
88   25  25         NA         NA     10      10    cluster        2
89   25  50         NA         NA     10      10    cluster        2
90   25 125         NA         NA     10      10    cluster        2
91   50  50         NA         NA     10      10    cluster        5
92   50 100         NA         NA     10      10    cluster        5
93   50 250         NA         NA     10      10    cluster        5
94  100 100         NA         NA     10      10    cluster       10
95  100 200         NA         NA     10      10    cluster       10
96  100 500         NA         NA     10      10    cluster       10
97   10  10 0.80000000 0.80000000      3       3     random       NA
98   10  10 0.80000000 0.50000000      3       3     random       NA
99   10  10 0.80000000 0.04081633      3       3     random       NA
100  10  10 0.50000000 0.80000000      3       3     random       NA
101  10  10 0.50000000 0.50000000      3       3     random       NA
102  10  10 0.50000000 0.02020202      3       3     random       NA
103  10  10 0.04081633 0.80000000      3       3     random       NA
104  10  10 0.04081633 0.50000000      3       3     random       NA
105  10  10 0.04081633 0.02020202      3       3     random       NA
106  10  20 0.80000000 0.80000000      3       3     random       NA
107  10  20 0.80000000 0.50000000      3       3     random       NA
108  10  20 0.80000000 0.02020202      3       3     random       NA
109  10  20 0.50000000 0.80000000      3       3     random       NA
110  10  20 0.50000000 0.50000000      3       3     random       NA
111  10  20 0.50000000 0.22222222      3       3     random       NA
112  10  20 0.02020202 0.80000000      3       3     random       NA
113  10  20 0.02020202 0.50000000      3       3     random       NA
114  10  20 0.02020202 0.22222222      3       3     random       NA
115  10  50 0.80000000 0.80000000      3       3     random       NA
116  10  50 0.80000000 0.50000000      3       3     random       NA
117  10  50 0.80000000 0.22222222      3       3     random       NA
118  10  50 0.50000000 0.80000000      3       3     random       NA
119  10  50 0.50000000 0.50000000      3       3     random       NA
120  10  50 0.50000000 0.08333333      3       3     random       NA
121  10  50 0.02020202 0.80000000      3       3     random       NA
122  10  50 0.02020202 0.50000000      3       3     random       NA
123  10  50 0.02020202 0.08333333      3       3     random       NA
124  25  25 0.80000000 0.80000000      3       3     random       NA
125  25  25 0.80000000 0.50000000      3       3     random       NA
126  25  25 0.80000000 0.08333333      3       3     random       NA
127  25  25 0.50000000 0.80000000      3       3     random       NA
128  25  25 0.50000000 0.50000000      3       3     random       NA
129  25  25 0.50000000 0.04081633      3       3     random       NA
130  25  25 0.02020202 0.80000000      3       3     random       NA
131  25  25 0.02020202 0.50000000      3       3     random       NA
132  25  25 0.02020202 0.04081633      3       3     random       NA
133  25  50 0.80000000 0.80000000      3       3     random       NA
134  25  50 0.80000000 0.50000000      3       3     random       NA
135  25  50 0.80000000 0.04081633      3       3     random       NA
136  25  50 0.50000000 0.80000000      3       3     random       NA
137  25  50 0.50000000 0.50000000      3       3     random       NA
138  25  50 0.50000000 0.02020202      3       3     random       NA
139  25  50 0.22222222 0.80000000      3       3     random       NA
140  25  50 0.22222222 0.50000000      3       3     random       NA
141  25  50 0.22222222 0.02020202      3       3     random       NA
142  25 125 0.80000000 0.80000000      3       3     random       NA
143  25 125 0.80000000 0.50000000      3       3     random       NA
144  25 125 0.80000000 0.02020202      3       3     random       NA
145  25 125 0.50000000 0.80000000      3       3     random       NA
146  25 125 0.50000000 0.50000000      3       3     random       NA
147  25 125 0.50000000 0.22222222      3       3     random       NA
148  25 125 0.22222222 0.80000000      3       3     random       NA
149  25 125 0.22222222 0.50000000      3       3     random       NA
150  25 125 0.22222222 0.22222222      3       3     random       NA
151  50  50 0.80000000 0.80000000      3       3     random       NA
152  50  50 0.80000000 0.50000000      3       3     random       NA
153  50  50 0.80000000 0.22222222      3       3     random       NA
154  50  50 0.50000000 0.80000000      3       3     random       NA
155  50  50 0.50000000 0.50000000      3       3     random       NA
156  50  50 0.50000000 0.08333333      3       3     random       NA
157  50  50 0.22222222 0.80000000      3       3     random       NA
158  50  50 0.22222222 0.50000000      3       3     random       NA
159  50  50 0.22222222 0.08333333      3       3     random       NA
160  50 100 0.80000000 0.80000000      3       3     random       NA
161  50 100 0.80000000 0.50000000      3       3     random       NA
162  50 100 0.80000000 0.08333333      3       3     random       NA
163  50 100 0.50000000 0.80000000      3       3     random       NA
164  50 100 0.50000000 0.50000000      3       3     random       NA
165  50 100 0.50000000 0.04081633      3       3     random       NA
166  50 100 0.08333333 0.80000000      3       3     random       NA
167  50 100 0.08333333 0.50000000      3       3     random       NA
168  50 100 0.08333333 0.04081633      3       3     random       NA
169  50 250 0.80000000 0.80000000      3       3     random       NA
170  50 250 0.80000000 0.50000000      3       3     random       NA
171  50 250 0.80000000 0.04081633      3       3     random       NA
172  50 250 0.50000000 0.80000000      3       3     random       NA
173  50 250 0.50000000 0.50000000      3       3     random       NA
174  50 250 0.50000000 0.02020202      3       3     random       NA
175  50 250 0.08333333 0.80000000      3       3     random       NA
176  50 250 0.08333333 0.50000000      3       3     random       NA
177  50 250 0.08333333 0.02020202      3       3     random       NA
178 100 100 0.80000000 0.80000000      3       3     random       NA
179 100 100 0.80000000 0.50000000      3       3     random       NA
180 100 100 0.80000000 0.02020202      3       3     random       NA
181 100 100 0.50000000 0.80000000      3       3     random       NA
182 100 100 0.50000000 0.50000000      3       3     random       NA
183 100 100 0.50000000 0.22222222      3       3     random       NA
184 100 100 0.08333333 0.80000000      3       3     random       NA
185 100 100 0.08333333 0.50000000      3       3     random       NA
186 100 100 0.08333333 0.22222222      3       3     random       NA
187 100 200 0.80000000 0.80000000      3       3     random       NA
188 100 200 0.80000000 0.50000000      3       3     random       NA
189 100 200 0.80000000 0.22222222      3       3     random       NA
190 100 200 0.50000000 0.80000000      3       3     random       NA
191 100 200 0.50000000 0.50000000      3       3     random       NA
192 100 200 0.50000000 0.08333333      3       3     random       NA
193 100 200 0.04081633 0.80000000      3       3     random       NA
194 100 200 0.04081633 0.50000000      3       3     random       NA
195 100 200 0.04081633 0.08333333      3       3     random       NA
196 100 500 0.80000000 0.80000000      3       3     random       NA
197 100 500 0.80000000 0.50000000      3       3     random       NA
198 100 500 0.80000000 0.08333333      3       3     random       NA
199 100 500 0.50000000 0.80000000      3       3     random       NA
200 100 500 0.50000000 0.50000000      3       3     random       NA
201 100 500 0.50000000 0.04081633      3       3     random       NA
202 100 500 0.04081633 0.80000000      3       3     random       NA
203 100 500 0.04081633 0.50000000      3       3     random       NA
204 100 500 0.04081633 0.04081633      3       3     random       NA
205  10  10 0.80000000 0.80000000     10       3     random       NA
206  10  10 0.80000000 0.50000000     10       3     random       NA
207  10  10 0.80000000 0.04081633     10       3     random       NA
208  10  10 0.50000000 0.80000000     10       3     random       NA
209  10  10 0.50000000 0.50000000     10       3     random       NA
210  10  10 0.50000000 0.02020202     10       3     random       NA
211  10  10 0.04081633 0.80000000     10       3     random       NA
212  10  10 0.04081633 0.50000000     10       3     random       NA
213  10  10 0.04081633 0.02020202     10       3     random       NA
214  10  20 0.80000000 0.80000000     10       3     random       NA
215  10  20 0.80000000 0.50000000     10       3     random       NA
216  10  20 0.80000000 0.02020202     10       3     random       NA
217  10  20 0.50000000 0.80000000     10       3     random       NA
218  10  20 0.50000000 0.50000000     10       3     random       NA
219  10  20 0.50000000 0.22222222     10       3     random       NA
220  10  20 0.02020202 0.80000000     10       3     random       NA
221  10  20 0.02020202 0.50000000     10       3     random       NA
222  10  20 0.02020202 0.22222222     10       3     random       NA
223  10  50 0.80000000 0.80000000     10       3     random       NA
224  10  50 0.80000000 0.50000000     10       3     random       NA
225  10  50 0.80000000 0.22222222     10       3     random       NA
226  10  50 0.50000000 0.80000000     10       3     random       NA
227  10  50 0.50000000 0.50000000     10       3     random       NA
228  10  50 0.50000000 0.08333333     10       3     random       NA
229  10  50 0.02020202 0.80000000     10       3     random       NA
230  10  50 0.02020202 0.50000000     10       3     random       NA
231  10  50 0.02020202 0.08333333     10       3     random       NA
232  25  25 0.80000000 0.80000000     10       3     random       NA
233  25  25 0.80000000 0.50000000     10       3     random       NA
234  25  25 0.80000000 0.08333333     10       3     random       NA
235  25  25 0.50000000 0.80000000     10       3     random       NA
236  25  25 0.50000000 0.50000000     10       3     random       NA
237  25  25 0.50000000 0.04081633     10       3     random       NA
238  25  25 0.02020202 0.80000000     10       3     random       NA
239  25  25 0.02020202 0.50000000     10       3     random       NA
240  25  25 0.02020202 0.04081633     10       3     random       NA
241  25  50 0.80000000 0.80000000     10       3     random       NA
242  25  50 0.80000000 0.50000000     10       3     random       NA
243  25  50 0.80000000 0.04081633     10       3     random       NA
244  25  50 0.50000000 0.80000000     10       3     random       NA
245  25  50 0.50000000 0.50000000     10       3     random       NA
246  25  50 0.50000000 0.02020202     10       3     random       NA
247  25  50 0.22222222 0.80000000     10       3     random       NA
248  25  50 0.22222222 0.50000000     10       3     random       NA
249  25  50 0.22222222 0.02020202     10       3     random       NA
250  25 125 0.80000000 0.80000000     10       3     random       NA
251  25 125 0.80000000 0.50000000     10       3     random       NA
252  25 125 0.80000000 0.02020202     10       3     random       NA
253  25 125 0.50000000 0.80000000     10       3     random       NA
254  25 125 0.50000000 0.50000000     10       3     random       NA
255  25 125 0.50000000 0.22222222     10       3     random       NA
256  25 125 0.22222222 0.80000000     10       3     random       NA
257  25 125 0.22222222 0.50000000     10       3     random       NA
258  25 125 0.22222222 0.22222222     10       3     random       NA
259  50  50 0.80000000 0.80000000     10       3     random       NA
260  50  50 0.80000000 0.50000000     10       3     random       NA
261  50  50 0.80000000 0.22222222     10       3     random       NA
262  50  50 0.50000000 0.80000000     10       3     random       NA
263  50  50 0.50000000 0.50000000     10       3     random       NA
264  50  50 0.50000000 0.08333333     10       3     random       NA
265  50  50 0.22222222 0.80000000     10       3     random       NA
266  50  50 0.22222222 0.50000000     10       3     random       NA
267  50  50 0.22222222 0.08333333     10       3     random       NA
268  50 100 0.80000000 0.80000000     10       3     random       NA
269  50 100 0.80000000 0.50000000     10       3     random       NA
270  50 100 0.80000000 0.08333333     10       3     random       NA
271  50 100 0.50000000 0.80000000     10       3     random       NA
272  50 100 0.50000000 0.50000000     10       3     random       NA
273  50 100 0.50000000 0.04081633     10       3     random       NA
274  50 100 0.08333333 0.80000000     10       3     random       NA
275  50 100 0.08333333 0.50000000     10       3     random       NA
276  50 100 0.08333333 0.04081633     10       3     random       NA
277  50 250 0.80000000 0.80000000     10       3     random       NA
278  50 250 0.80000000 0.50000000     10       3     random       NA
279  50 250 0.80000000 0.04081633     10       3     random       NA
280  50 250 0.50000000 0.80000000     10       3     random       NA
281  50 250 0.50000000 0.50000000     10       3     random       NA
282  50 250 0.50000000 0.02020202     10       3     random       NA
283  50 250 0.08333333 0.80000000     10       3     random       NA
284  50 250 0.08333333 0.50000000     10       3     random       NA
285  50 250 0.08333333 0.02020202     10       3     random       NA
286 100 100 0.80000000 0.80000000     10       3     random       NA
287 100 100 0.80000000 0.50000000     10       3     random       NA
288 100 100 0.80000000 0.02020202     10       3     random       NA
289 100 100 0.50000000 0.80000000     10       3     random       NA
290 100 100 0.50000000 0.50000000     10       3     random       NA
291 100 100 0.50000000 0.22222222     10       3     random       NA
292 100 100 0.08333333 0.80000000     10       3     random       NA
293 100 100 0.08333333 0.50000000     10       3     random       NA
294 100 100 0.08333333 0.22222222     10       3     random       NA
295 100 200 0.80000000 0.80000000     10       3     random       NA
296 100 200 0.80000000 0.50000000     10       3     random       NA
297 100 200 0.80000000 0.22222222     10       3     random       NA
298 100 200 0.50000000 0.80000000     10       3     random       NA
299 100 200 0.50000000 0.50000000     10       3     random       NA
300 100 200 0.50000000 0.08333333     10       3     random       NA
301 100 200 0.04081633 0.80000000     10       3     random       NA
302 100 200 0.04081633 0.50000000     10       3     random       NA
303 100 200 0.04081633 0.08333333     10       3     random       NA
304 100 500 0.80000000 0.80000000     10       3     random       NA
305 100 500 0.80000000 0.50000000     10       3     random       NA
306 100 500 0.80000000 0.08333333     10       3     random       NA
307 100 500 0.50000000 0.80000000     10       3     random       NA
308 100 500 0.50000000 0.50000000     10       3     random       NA
309 100 500 0.50000000 0.04081633     10       3     random       NA
310 100 500 0.04081633 0.80000000     10       3     random       NA
311 100 500 0.04081633 0.50000000     10       3     random       NA
312 100 500 0.04081633 0.04081633     10       3     random       NA
313  10  10 0.80000000 0.80000000      3      10     random       NA
314  10  10 0.80000000 0.50000000      3      10     random       NA
315  10  10 0.80000000 0.04081633      3      10     random       NA
316  10  10 0.50000000 0.80000000      3      10     random       NA
317  10  10 0.50000000 0.50000000      3      10     random       NA
318  10  10 0.50000000 0.02020202      3      10     random       NA
319  10  10 0.04081633 0.80000000      3      10     random       NA
320  10  10 0.04081633 0.50000000      3      10     random       NA
321  10  10 0.04081633 0.02020202      3      10     random       NA
322  10  20 0.80000000 0.80000000      3      10     random       NA
323  10  20 0.80000000 0.50000000      3      10     random       NA
324  10  20 0.80000000 0.02020202      3      10     random       NA
325  10  20 0.50000000 0.80000000      3      10     random       NA
326  10  20 0.50000000 0.50000000      3      10     random       NA
327  10  20 0.50000000 0.22222222      3      10     random       NA
328  10  20 0.02020202 0.80000000      3      10     random       NA
329  10  20 0.02020202 0.50000000      3      10     random       NA
330  10  20 0.02020202 0.22222222      3      10     random       NA
331  10  50 0.80000000 0.80000000      3      10     random       NA
332  10  50 0.80000000 0.50000000      3      10     random       NA
333  10  50 0.80000000 0.22222222      3      10     random       NA
334  10  50 0.50000000 0.80000000      3      10     random       NA
335  10  50 0.50000000 0.50000000      3      10     random       NA
336  10  50 0.50000000 0.08333333      3      10     random       NA
337  10  50 0.02020202 0.80000000      3      10     random       NA
338  10  50 0.02020202 0.50000000      3      10     random       NA
339  10  50 0.02020202 0.08333333      3      10     random       NA
340  25  25 0.80000000 0.80000000      3      10     random       NA
341  25  25 0.80000000 0.50000000      3      10     random       NA
342  25  25 0.80000000 0.08333333      3      10     random       NA
343  25  25 0.50000000 0.80000000      3      10     random       NA
344  25  25 0.50000000 0.50000000      3      10     random       NA
345  25  25 0.50000000 0.04081633      3      10     random       NA
346  25  25 0.02020202 0.80000000      3      10     random       NA
347  25  25 0.02020202 0.50000000      3      10     random       NA
348  25  25 0.02020202 0.04081633      3      10     random       NA
349  25  50 0.80000000 0.80000000      3      10     random       NA
350  25  50 0.80000000 0.50000000      3      10     random       NA
351  25  50 0.80000000 0.04081633      3      10     random       NA
352  25  50 0.50000000 0.80000000      3      10     random       NA
353  25  50 0.50000000 0.50000000      3      10     random       NA
354  25  50 0.50000000 0.02020202      3      10     random       NA
355  25  50 0.22222222 0.80000000      3      10     random       NA
356  25  50 0.22222222 0.50000000      3      10     random       NA
357  25  50 0.22222222 0.02020202      3      10     random       NA
358  25 125 0.80000000 0.80000000      3      10     random       NA
359  25 125 0.80000000 0.50000000      3      10     random       NA
360  25 125 0.80000000 0.02020202      3      10     random       NA
361  25 125 0.50000000 0.80000000      3      10     random       NA
362  25 125 0.50000000 0.50000000      3      10     random       NA
363  25 125 0.50000000 0.22222222      3      10     random       NA
364  25 125 0.22222222 0.80000000      3      10     random       NA
365  25 125 0.22222222 0.50000000      3      10     random       NA
366  25 125 0.22222222 0.22222222      3      10     random       NA
367  50  50 0.80000000 0.80000000      3      10     random       NA
368  50  50 0.80000000 0.50000000      3      10     random       NA
369  50  50 0.80000000 0.22222222      3      10     random       NA
370  50  50 0.50000000 0.80000000      3      10     random       NA
371  50  50 0.50000000 0.50000000      3      10     random       NA
372  50  50 0.50000000 0.08333333      3      10     random       NA
373  50  50 0.22222222 0.80000000      3      10     random       NA
374  50  50 0.22222222 0.50000000      3      10     random       NA
375  50  50 0.22222222 0.08333333      3      10     random       NA
376  50 100 0.80000000 0.80000000      3      10     random       NA
377  50 100 0.80000000 0.50000000      3      10     random       NA
378  50 100 0.80000000 0.08333333      3      10     random       NA
379  50 100 0.50000000 0.80000000      3      10     random       NA
380  50 100 0.50000000 0.50000000      3      10     random       NA
381  50 100 0.50000000 0.04081633      3      10     random       NA
382  50 100 0.08333333 0.80000000      3      10     random       NA
383  50 100 0.08333333 0.50000000      3      10     random       NA
384  50 100 0.08333333 0.04081633      3      10     random       NA
385  50 250 0.80000000 0.80000000      3      10     random       NA
386  50 250 0.80000000 0.50000000      3      10     random       NA
387  50 250 0.80000000 0.04081633      3      10     random       NA
388  50 250 0.50000000 0.80000000      3      10     random       NA
389  50 250 0.50000000 0.50000000      3      10     random       NA
390  50 250 0.50000000 0.02020202      3      10     random       NA
391  50 250 0.08333333 0.80000000      3      10     random       NA
392  50 250 0.08333333 0.50000000      3      10     random       NA
393  50 250 0.08333333 0.02020202      3      10     random       NA
394 100 100 0.80000000 0.80000000      3      10     random       NA
395 100 100 0.80000000 0.50000000      3      10     random       NA
396 100 100 0.80000000 0.02020202      3      10     random       NA
397 100 100 0.50000000 0.80000000      3      10     random       NA
398 100 100 0.50000000 0.50000000      3      10     random       NA
399 100 100 0.50000000 0.22222222      3      10     random       NA
400 100 100 0.08333333 0.80000000      3      10     random       NA
401 100 100 0.08333333 0.50000000      3      10     random       NA
402 100 100 0.08333333 0.22222222      3      10     random       NA
403 100 200 0.80000000 0.80000000      3      10     random       NA
404 100 200 0.80000000 0.50000000      3      10     random       NA
405 100 200 0.80000000 0.22222222      3      10     random       NA
406 100 200 0.50000000 0.80000000      3      10     random       NA
407 100 200 0.50000000 0.50000000      3      10     random       NA
408 100 200 0.50000000 0.08333333      3      10     random       NA
409 100 200 0.04081633 0.80000000      3      10     random       NA
410 100 200 0.04081633 0.50000000      3      10     random       NA
411 100 200 0.04081633 0.08333333      3      10     random       NA
412 100 500 0.80000000 0.80000000      3      10     random       NA
413 100 500 0.80000000 0.50000000      3      10     random       NA
414 100 500 0.80000000 0.08333333      3      10     random       NA
415 100 500 0.50000000 0.80000000      3      10     random       NA
416 100 500 0.50000000 0.50000000      3      10     random       NA
417 100 500 0.50000000 0.04081633      3      10     random       NA
418 100 500 0.04081633 0.80000000      3      10     random       NA
419 100 500 0.04081633 0.50000000      3      10     random       NA
420 100 500 0.04081633 0.04081633      3      10     random       NA
421  10  10 0.80000000 0.80000000     10      10     random       NA
422  10  10 0.80000000 0.50000000     10      10     random       NA
423  10  10 0.80000000 0.04081633     10      10     random       NA
424  10  10 0.50000000 0.80000000     10      10     random       NA
425  10  10 0.50000000 0.50000000     10      10     random       NA
426  10  10 0.50000000 0.02020202     10      10     random       NA
427  10  10 0.04081633 0.80000000     10      10     random       NA
428  10  10 0.04081633 0.50000000     10      10     random       NA
429  10  10 0.04081633 0.02020202     10      10     random       NA
430  10  20 0.80000000 0.80000000     10      10     random       NA
431  10  20 0.80000000 0.50000000     10      10     random       NA
432  10  20 0.80000000 0.02020202     10      10     random       NA
433  10  20 0.50000000 0.80000000     10      10     random       NA
434  10  20 0.50000000 0.50000000     10      10     random       NA
435  10  20 0.50000000 0.22222222     10      10     random       NA
436  10  20 0.02020202 0.80000000     10      10     random       NA
437  10  20 0.02020202 0.50000000     10      10     random       NA
438  10  20 0.02020202 0.22222222     10      10     random       NA
439  10  50 0.80000000 0.80000000     10      10     random       NA
440  10  50 0.80000000 0.50000000     10      10     random       NA
441  10  50 0.80000000 0.22222222     10      10     random       NA
442  10  50 0.50000000 0.80000000     10      10     random       NA
443  10  50 0.50000000 0.50000000     10      10     random       NA
444  10  50 0.50000000 0.08333333     10      10     random       NA
445  10  50 0.02020202 0.80000000     10      10     random       NA
446  10  50 0.02020202 0.50000000     10      10     random       NA
447  10  50 0.02020202 0.08333333     10      10     random       NA
448  25  25 0.80000000 0.80000000     10      10     random       NA
449  25  25 0.80000000 0.50000000     10      10     random       NA
450  25  25 0.80000000 0.08333333     10      10     random       NA
451  25  25 0.50000000 0.80000000     10      10     random       NA
452  25  25 0.50000000 0.50000000     10      10     random       NA
453  25  25 0.50000000 0.04081633     10      10     random       NA
454  25  25 0.02020202 0.80000000     10      10     random       NA
455  25  25 0.02020202 0.50000000     10      10     random       NA
456  25  25 0.02020202 0.04081633     10      10     random       NA
457  25  50 0.80000000 0.80000000     10      10     random       NA
458  25  50 0.80000000 0.50000000     10      10     random       NA
459  25  50 0.80000000 0.04081633     10      10     random       NA
460  25  50 0.50000000 0.80000000     10      10     random       NA
461  25  50 0.50000000 0.50000000     10      10     random       NA
462  25  50 0.50000000 0.02020202     10      10     random       NA
463  25  50 0.22222222 0.80000000     10      10     random       NA
464  25  50 0.22222222 0.50000000     10      10     random       NA
465  25  50 0.22222222 0.02020202     10      10     random       NA
466  25 125 0.80000000 0.80000000     10      10     random       NA
467  25 125 0.80000000 0.50000000     10      10     random       NA
468  25 125 0.80000000 0.02020202     10      10     random       NA
469  25 125 0.50000000 0.80000000     10      10     random       NA
470  25 125 0.50000000 0.50000000     10      10     random       NA
471  25 125 0.50000000 0.22222222     10      10     random       NA
472  25 125 0.22222222 0.80000000     10      10     random       NA
473  25 125 0.22222222 0.50000000     10      10     random       NA
474  25 125 0.22222222 0.22222222     10      10     random       NA
475  50  50 0.80000000 0.80000000     10      10     random       NA
476  50  50 0.80000000 0.50000000     10      10     random       NA
477  50  50 0.80000000 0.22222222     10      10     random       NA
478  50  50 0.50000000 0.80000000     10      10     random       NA
479  50  50 0.50000000 0.50000000     10      10     random       NA
480  50  50 0.50000000 0.08333333     10      10     random       NA
481  50  50 0.22222222 0.80000000     10      10     random       NA
482  50  50 0.22222222 0.50000000     10      10     random       NA
483  50  50 0.22222222 0.08333333     10      10     random       NA
484  50 100 0.80000000 0.80000000     10      10     random       NA
485  50 100 0.80000000 0.50000000     10      10     random       NA
486  50 100 0.80000000 0.08333333     10      10     random       NA
487  50 100 0.50000000 0.80000000     10      10     random       NA
488  50 100 0.50000000 0.50000000     10      10     random       NA
489  50 100 0.50000000 0.04081633     10      10     random       NA
490  50 100 0.08333333 0.80000000     10      10     random       NA
491  50 100 0.08333333 0.50000000     10      10     random       NA
492  50 100 0.08333333 0.04081633     10      10     random       NA
493  50 250 0.80000000 0.80000000     10      10     random       NA
494  50 250 0.80000000 0.50000000     10      10     random       NA
495  50 250 0.80000000 0.04081633     10      10     random       NA
496  50 250 0.50000000 0.80000000     10      10     random       NA
497  50 250 0.50000000 0.50000000     10      10     random       NA
498  50 250 0.50000000 0.02020202     10      10     random       NA
499  50 250 0.08333333 0.80000000     10      10     random       NA
500  50 250 0.08333333 0.50000000     10      10     random       NA
501  50 250 0.08333333 0.02020202     10      10     random       NA
502 100 100 0.80000000 0.80000000     10      10     random       NA
503 100 100 0.80000000 0.50000000     10      10     random       NA
504 100 100 0.80000000 0.02020202     10      10     random       NA
505 100 100 0.50000000 0.80000000     10      10     random       NA
506 100 100 0.50000000 0.50000000     10      10     random       NA
507 100 100 0.50000000 0.22222222     10      10     random       NA
508 100 100 0.08333333 0.80000000     10      10     random       NA
509 100 100 0.08333333 0.50000000     10      10     random       NA
510 100 100 0.08333333 0.22222222     10      10     random       NA
511 100 200 0.80000000 0.80000000     10      10     random       NA
512 100 200 0.80000000 0.50000000     10      10     random       NA
513 100 200 0.80000000 0.22222222     10      10     random       NA
514 100 200 0.50000000 0.80000000     10      10     random       NA
515 100 200 0.50000000 0.50000000     10      10     random       NA
516 100 200 0.50000000 0.08333333     10      10     random       NA
517 100 200 0.04081633 0.80000000     10      10     random       NA
518 100 200 0.04081633 0.50000000     10      10     random       NA
519 100 200 0.04081633 0.08333333     10      10     random       NA
520 100 500 0.80000000 0.80000000     10      10     random       NA
521 100 500 0.80000000 0.50000000     10      10     random       NA
522 100 500 0.80000000 0.08333333     10      10     random       NA
523 100 500 0.50000000 0.80000000     10      10     random       NA
524 100 500 0.50000000 0.50000000     10      10     random       NA
525 100 500 0.50000000 0.04081633     10      10     random       NA
526 100 500 0.04081633 0.80000000     10      10     random       NA
527 100 500 0.04081633 0.50000000     10      10     random       NA
528 100 500 0.04081633 0.04081633     10      10     random       NA
> i=1
> 528/4
[1] 132
> 528/12
[1] 44
> 528/24
[1] 22
> 258 %%24
[1] 18
> 258 %/%24
[1] 10
> 528 %% 24
[1] 0
> params <- conditions_grid[i, ]
+   print(params)
>    p  n true_g prior_g true_b prior_b graph_type clusters
1 10 10     NA      NA      3       3 scale-free       NA
> tep=1
> rep=1
> rm(tep)
> data  <-  bdgraph.sim(
+       p = params$p,
+       graph = params$graph_type,
+       n = params$n,
+       type = "Gaussian",
+       prob = 0.9,#params$true_g,
+       b = params$true_b,
+       class = params$clusters
+     )
> G_true <- data$G
+     K_true <- data$K
> # --- 2.2. Run the BDMCMC Algorithm ---
+     sample_bd <- bdgraph(
+       data = data$data,
+       algorithm = "bdmcmc",
+       iter = 5000,
+       g.prior = params$g_prior,
+       df.prior = params$b_prior,
+       save = TRUE
+     )
+     summary_bd <- summary(sample_bd)
Error in if (df.prior < 3) stop("'prior.df' must be >= 3") : 
  argument is of length zero
> Error: object 'sample_bd' not found
> # Project start
+ library(BDgraph)
+ library(qgraph)
+ library(pROC)
> # --- 2.2. Run the BDMCMC Algorithm ---
+     sample_bd <- bdgraph(
+       data = data$data,
+       algorithm = "bdmcmc",
+       iter = 5000,
+       g.prior = params$g_prior,
+       df.prior = params$b_prior,
+       save = TRUE
+     )
Error in if (df.prior < 3) stop("'prior.df' must be >= 3") : 
  argument is of length zero
> 
> # --- 2.2. Run the BDMCMC Algorithm ---
+     sample_bd <- bdgraph(
+       data = data$data,
+       algorithm = "bdmcmc",
+       iter = 5000,
+       g.prior = params$prior_g,
+       df.prior = params$prior_b,
+       save = TRUE
+     )
Error in if ((g.prior <= 0) | (g.prior >= 1)) stop("'g.prior' must be between 0 and 1") : 
  missing value where TRUE/FALSE needed
> conditions_grid <- expand.grid(
+   p = rep(p, each=3),
+   n = NA,
+   true_g = 3,
+   prior_g = 3,
+   #true_rho = dgp_rho, # sparsity prior
+   #prior_g = model_g,
+   true_b = dgp_b,
+   prior_b = model_b,
+   graph_type = c("scale-free", "random", "cluster")
+   )
> conditions_grid$n  <- conditions_grid$p * c(1,2,5)
> # Define the true edge probabilities
+ row_indices3 <- rep(which(conditions_grid$graph_type == "random"), each = 3)
+ expanded_grid3 <- conditions_grid[row_indices3, ]
> prob_vector <- unlist(lapply(conditions_grid$p, function(p_val) {
+   # The vector of two probability values to be created for each p
+   c( 0.8, 0.5, 2 / (p_val - 1)) } ) )
> conditions_grid <- rbind(conditions_grid[conditions_grid$graph_type != 'random',], expanded_grid3)
+ conditions_grid$true_g <- ifelse(conditions_grid$graph_type == "random", prob_vector, NA)
> # Define the misspecified prior edge probabilities
+ row_indices2 <- rep(which(conditions_grid$graph_type == "random"), each = 3)
+ expanded_grid2 <- conditions_grid[row_indices2, ]
> conditions_grid <- rbind(conditions_grid[conditions_grid$graph_type != 'random',], expanded_grid2)
+ conditions_grid$prior_g <- ifelse(conditions_grid$graph_type == "random", prob_vector, NA)
> # Define the number of clusters
+ conditions_grid$clusters <- ifelse(conditions_grid$graph_type == "cluster",
+                                    pmax(2, floor(conditions_grid$p/10)), NA)
> # Fixing the row names
+ rownames(conditions_grid) <- seq(nrow(conditions_grid))
> mcmc_iter <- 5000
> burnin <- 2000
> num_chains <- 4 # Number of chains for convergence diagnostics
> results_df <- data.frame()
> conditions_grid
      p   n     true_g    prior_g true_b prior_b graph_type clusters
1    10  10         NA         NA      3       3 scale-free       NA
2    10  20         NA         NA      3       3 scale-free       NA
3    10  50         NA         NA      3       3 scale-free       NA
4    25  25         NA         NA      3       3 scale-free       NA
5    25  50         NA         NA      3       3 scale-free       NA
6    25 125         NA         NA      3       3 scale-free       NA
7    50  50         NA         NA      3       3 scale-free       NA
8    50 100         NA         NA      3       3 scale-free       NA
9    50 250         NA         NA      3       3 scale-free       NA
10  100 100         NA         NA      3       3 scale-free       NA
11  100 200         NA         NA      3       3 scale-free       NA
12  100 500         NA         NA      3       3 scale-free       NA
13   10  10         NA         NA     10       3 scale-free       NA
14   10  20         NA         NA     10       3 scale-free       NA
15   10  50         NA         NA     10       3 scale-free       NA
16   25  25         NA         NA     10       3 scale-free       NA
17   25  50         NA         NA     10       3 scale-free       NA
18   25 125         NA         NA     10       3 scale-free       NA
19   50  50         NA         NA     10       3 scale-free       NA
20   50 100         NA         NA     10       3 scale-free       NA
21   50 250         NA         NA     10       3 scale-free       NA
22  100 100         NA         NA     10       3 scale-free       NA
23  100 200         NA         NA     10       3 scale-free       NA
24  100 500         NA         NA     10       3 scale-free       NA
25   10  10         NA         NA      3      10 scale-free       NA
26   10  20         NA         NA      3      10 scale-free       NA
27   10  50         NA         NA      3      10 scale-free       NA
28   25  25         NA         NA      3      10 scale-free       NA
29   25  50         NA         NA      3      10 scale-free       NA
30   25 125         NA         NA      3      10 scale-free       NA
31   50  50         NA         NA      3      10 scale-free       NA
32   50 100         NA         NA      3      10 scale-free       NA
33   50 250         NA         NA      3      10 scale-free       NA
34  100 100         NA         NA      3      10 scale-free       NA
35  100 200         NA         NA      3      10 scale-free       NA
36  100 500         NA         NA      3      10 scale-free       NA
37   10  10         NA         NA     10      10 scale-free       NA
38   10  20         NA         NA     10      10 scale-free       NA
39   10  50         NA         NA     10      10 scale-free       NA
40   25  25         NA         NA     10      10 scale-free       NA
41   25  50         NA         NA     10      10 scale-free       NA
42   25 125         NA         NA     10      10 scale-free       NA
43   50  50         NA         NA     10      10 scale-free       NA
44   50 100         NA         NA     10      10 scale-free       NA
45   50 250         NA         NA     10      10 scale-free       NA
46  100 100         NA         NA     10      10 scale-free       NA
47  100 200         NA         NA     10      10 scale-free       NA
48  100 500         NA         NA     10      10 scale-free       NA
49   10  10         NA         NA      3       3    cluster        2
50   10  20         NA         NA      3       3    cluster        2
51   10  50         NA         NA      3       3    cluster        2
52   25  25         NA         NA      3       3    cluster        2
53   25  50         NA         NA      3       3    cluster        2
54   25 125         NA         NA      3       3    cluster        2
55   50  50         NA         NA      3       3    cluster        5
56   50 100         NA         NA      3       3    cluster        5
57   50 250         NA         NA      3       3    cluster        5
58  100 100         NA         NA      3       3    cluster       10
59  100 200         NA         NA      3       3    cluster       10
60  100 500         NA         NA      3       3    cluster       10
61   10  10         NA         NA     10       3    cluster        2
62   10  20         NA         NA     10       3    cluster        2
63   10  50         NA         NA     10       3    cluster        2
64   25  25         NA         NA     10       3    cluster        2
65   25  50         NA         NA     10       3    cluster        2
66   25 125         NA         NA     10       3    cluster        2
67   50  50         NA         NA     10       3    cluster        5
68   50 100         NA         NA     10       3    cluster        5
69   50 250         NA         NA     10       3    cluster        5
70  100 100         NA         NA     10       3    cluster       10
71  100 200         NA         NA     10       3    cluster       10
72  100 500         NA         NA     10       3    cluster       10
73   10  10         NA         NA      3      10    cluster        2
74   10  20         NA         NA      3      10    cluster        2
75   10  50         NA         NA      3      10    cluster        2
76   25  25         NA         NA      3      10    cluster        2
77   25  50         NA         NA      3      10    cluster        2
78   25 125         NA         NA      3      10    cluster        2
79   50  50         NA         NA      3      10    cluster        5
80   50 100         NA         NA      3      10    cluster        5
81   50 250         NA         NA      3      10    cluster        5
82  100 100         NA         NA      3      10    cluster       10
83  100 200         NA         NA      3      10    cluster       10
84  100 500         NA         NA      3      10    cluster       10
85   10  10         NA         NA     10      10    cluster        2
86   10  20         NA         NA     10      10    cluster        2
87   10  50         NA         NA     10      10    cluster        2
88   25  25         NA         NA     10      10    cluster        2
89   25  50         NA         NA     10      10    cluster        2
90   25 125         NA         NA     10      10    cluster        2
91   50  50         NA         NA     10      10    cluster        5
92   50 100         NA         NA     10      10    cluster        5
93   50 250         NA         NA     10      10    cluster        5
94  100 100         NA         NA     10      10    cluster       10
95  100 200         NA         NA     10      10    cluster       10
96  100 500         NA         NA     10      10    cluster       10
97   10  10 0.80000000 0.80000000      3       3     random       NA
98   10  10 0.80000000 0.50000000      3       3     random       NA
99   10  10 0.80000000 0.04081633      3       3     random       NA
100  10  10 0.50000000 0.80000000      3       3     random       NA
101  10  10 0.50000000 0.50000000      3       3     random       NA
102  10  10 0.50000000 0.02020202      3       3     random       NA
103  10  10 0.04081633 0.80000000      3       3     random       NA
104  10  10 0.04081633 0.50000000      3       3     random       NA
105  10  10 0.04081633 0.02020202      3       3     random       NA
106  10  20 0.80000000 0.80000000      3       3     random       NA
107  10  20 0.80000000 0.50000000      3       3     random       NA
108  10  20 0.80000000 0.02020202      3       3     random       NA
109  10  20 0.50000000 0.80000000      3       3     random       NA
110  10  20 0.50000000 0.50000000      3       3     random       NA
111  10  20 0.50000000 0.22222222      3       3     random       NA
112  10  20 0.02020202 0.80000000      3       3     random       NA
113  10  20 0.02020202 0.50000000      3       3     random       NA
114  10  20 0.02020202 0.22222222      3       3     random       NA
115  10  50 0.80000000 0.80000000      3       3     random       NA
116  10  50 0.80000000 0.50000000      3       3     random       NA
117  10  50 0.80000000 0.22222222      3       3     random       NA
118  10  50 0.50000000 0.80000000      3       3     random       NA
119  10  50 0.50000000 0.50000000      3       3     random       NA
120  10  50 0.50000000 0.08333333      3       3     random       NA
121  10  50 0.02020202 0.80000000      3       3     random       NA
122  10  50 0.02020202 0.50000000      3       3     random       NA
123  10  50 0.02020202 0.08333333      3       3     random       NA
124  25  25 0.80000000 0.80000000      3       3     random       NA
125  25  25 0.80000000 0.50000000      3       3     random       NA
126  25  25 0.80000000 0.08333333      3       3     random       NA
127  25  25 0.50000000 0.80000000      3       3     random       NA
128  25  25 0.50000000 0.50000000      3       3     random       NA
129  25  25 0.50000000 0.04081633      3       3     random       NA
130  25  25 0.02020202 0.80000000      3       3     random       NA
131  25  25 0.02020202 0.50000000      3       3     random       NA
132  25  25 0.02020202 0.04081633      3       3     random       NA
133  25  50 0.80000000 0.80000000      3       3     random       NA
134  25  50 0.80000000 0.50000000      3       3     random       NA
135  25  50 0.80000000 0.04081633      3       3     random       NA
136  25  50 0.50000000 0.80000000      3       3     random       NA
137  25  50 0.50000000 0.50000000      3       3     random       NA
138  25  50 0.50000000 0.02020202      3       3     random       NA
139  25  50 0.22222222 0.80000000      3       3     random       NA
140  25  50 0.22222222 0.50000000      3       3     random       NA
141  25  50 0.22222222 0.02020202      3       3     random       NA
142  25 125 0.80000000 0.80000000      3       3     random       NA
143  25 125 0.80000000 0.50000000      3       3     random       NA
144  25 125 0.80000000 0.02020202      3       3     random       NA
145  25 125 0.50000000 0.80000000      3       3     random       NA
146  25 125 0.50000000 0.50000000      3       3     random       NA
147  25 125 0.50000000 0.22222222      3       3     random       NA
148  25 125 0.22222222 0.80000000      3       3     random       NA
149  25 125 0.22222222 0.50000000      3       3     random       NA
150  25 125 0.22222222 0.22222222      3       3     random       NA
151  50  50 0.80000000 0.80000000      3       3     random       NA
152  50  50 0.80000000 0.50000000      3       3     random       NA
153  50  50 0.80000000 0.22222222      3       3     random       NA
154  50  50 0.50000000 0.80000000      3       3     random       NA
155  50  50 0.50000000 0.50000000      3       3     random       NA
156  50  50 0.50000000 0.08333333      3       3     random       NA
157  50  50 0.22222222 0.80000000      3       3     random       NA
158  50  50 0.22222222 0.50000000      3       3     random       NA
159  50  50 0.22222222 0.08333333      3       3     random       NA
160  50 100 0.80000000 0.80000000      3       3     random       NA
161  50 100 0.80000000 0.50000000      3       3     random       NA
162  50 100 0.80000000 0.08333333      3       3     random       NA
163  50 100 0.50000000 0.80000000      3       3     random       NA
164  50 100 0.50000000 0.50000000      3       3     random       NA
165  50 100 0.50000000 0.04081633      3       3     random       NA
166  50 100 0.08333333 0.80000000      3       3     random       NA
167  50 100 0.08333333 0.50000000      3       3     random       NA
168  50 100 0.08333333 0.04081633      3       3     random       NA
169  50 250 0.80000000 0.80000000      3       3     random       NA
170  50 250 0.80000000 0.50000000      3       3     random       NA
171  50 250 0.80000000 0.04081633      3       3     random       NA
172  50 250 0.50000000 0.80000000      3       3     random       NA
173  50 250 0.50000000 0.50000000      3       3     random       NA
174  50 250 0.50000000 0.02020202      3       3     random       NA
175  50 250 0.08333333 0.80000000      3       3     random       NA
176  50 250 0.08333333 0.50000000      3       3     random       NA
177  50 250 0.08333333 0.02020202      3       3     random       NA
178 100 100 0.80000000 0.80000000      3       3     random       NA
179 100 100 0.80000000 0.50000000      3       3     random       NA
180 100 100 0.80000000 0.02020202      3       3     random       NA
181 100 100 0.50000000 0.80000000      3       3     random       NA
182 100 100 0.50000000 0.50000000      3       3     random       NA
183 100 100 0.50000000 0.22222222      3       3     random       NA
184 100 100 0.08333333 0.80000000      3       3     random       NA
185 100 100 0.08333333 0.50000000      3       3     random       NA
186 100 100 0.08333333 0.22222222      3       3     random       NA
187 100 200 0.80000000 0.80000000      3       3     random       NA
188 100 200 0.80000000 0.50000000      3       3     random       NA
189 100 200 0.80000000 0.22222222      3       3     random       NA
190 100 200 0.50000000 0.80000000      3       3     random       NA
191 100 200 0.50000000 0.50000000      3       3     random       NA
192 100 200 0.50000000 0.08333333      3       3     random       NA
193 100 200 0.04081633 0.80000000      3       3     random       NA
194 100 200 0.04081633 0.50000000      3       3     random       NA
195 100 200 0.04081633 0.08333333      3       3     random       NA
196 100 500 0.80000000 0.80000000      3       3     random       NA
197 100 500 0.80000000 0.50000000      3       3     random       NA
198 100 500 0.80000000 0.08333333      3       3     random       NA
199 100 500 0.50000000 0.80000000      3       3     random       NA
200 100 500 0.50000000 0.50000000      3       3     random       NA
201 100 500 0.50000000 0.04081633      3       3     random       NA
202 100 500 0.04081633 0.80000000      3       3     random       NA
203 100 500 0.04081633 0.50000000      3       3     random       NA
204 100 500 0.04081633 0.04081633      3       3     random       NA
205  10  10 0.80000000 0.80000000     10       3     random       NA
206  10  10 0.80000000 0.50000000     10       3     random       NA
207  10  10 0.80000000 0.04081633     10       3     random       NA
208  10  10 0.50000000 0.80000000     10       3     random       NA
209  10  10 0.50000000 0.50000000     10       3     random       NA
210  10  10 0.50000000 0.02020202     10       3     random       NA
211  10  10 0.04081633 0.80000000     10       3     random       NA
212  10  10 0.04081633 0.50000000     10       3     random       NA
213  10  10 0.04081633 0.02020202     10       3     random       NA
214  10  20 0.80000000 0.80000000     10       3     random       NA
215  10  20 0.80000000 0.50000000     10       3     random       NA
216  10  20 0.80000000 0.02020202     10       3     random       NA
217  10  20 0.50000000 0.80000000     10       3     random       NA
218  10  20 0.50000000 0.50000000     10       3     random       NA
219  10  20 0.50000000 0.22222222     10       3     random       NA
220  10  20 0.02020202 0.80000000     10       3     random       NA
221  10  20 0.02020202 0.50000000     10       3     random       NA
222  10  20 0.02020202 0.22222222     10       3     random       NA
223  10  50 0.80000000 0.80000000     10       3     random       NA
224  10  50 0.80000000 0.50000000     10       3     random       NA
225  10  50 0.80000000 0.22222222     10       3     random       NA
226  10  50 0.50000000 0.80000000     10       3     random       NA
227  10  50 0.50000000 0.50000000     10       3     random       NA
228  10  50 0.50000000 0.08333333     10       3     random       NA
229  10  50 0.02020202 0.80000000     10       3     random       NA
230  10  50 0.02020202 0.50000000     10       3     random       NA
231  10  50 0.02020202 0.08333333     10       3     random       NA
232  25  25 0.80000000 0.80000000     10       3     random       NA
233  25  25 0.80000000 0.50000000     10       3     random       NA
234  25  25 0.80000000 0.08333333     10       3     random       NA
235  25  25 0.50000000 0.80000000     10       3     random       NA
236  25  25 0.50000000 0.50000000     10       3     random       NA
237  25  25 0.50000000 0.04081633     10       3     random       NA
238  25  25 0.02020202 0.80000000     10       3     random       NA
239  25  25 0.02020202 0.50000000     10       3     random       NA
240  25  25 0.02020202 0.04081633     10       3     random       NA
241  25  50 0.80000000 0.80000000     10       3     random       NA
242  25  50 0.80000000 0.50000000     10       3     random       NA
243  25  50 0.80000000 0.04081633     10       3     random       NA
244  25  50 0.50000000 0.80000000     10       3     random       NA
245  25  50 0.50000000 0.50000000     10       3     random       NA
246  25  50 0.50000000 0.02020202     10       3     random       NA
247  25  50 0.22222222 0.80000000     10       3     random       NA
248  25  50 0.22222222 0.50000000     10       3     random       NA
249  25  50 0.22222222 0.02020202     10       3     random       NA
250  25 125 0.80000000 0.80000000     10       3     random       NA
251  25 125 0.80000000 0.50000000     10       3     random       NA
252  25 125 0.80000000 0.02020202     10       3     random       NA
253  25 125 0.50000000 0.80000000     10       3     random       NA
254  25 125 0.50000000 0.50000000     10       3     random       NA
255  25 125 0.50000000 0.22222222     10       3     random       NA
256  25 125 0.22222222 0.80000000     10       3     random       NA
257  25 125 0.22222222 0.50000000     10       3     random       NA
258  25 125 0.22222222 0.22222222     10       3     random       NA
259  50  50 0.80000000 0.80000000     10       3     random       NA
260  50  50 0.80000000 0.50000000     10       3     random       NA
261  50  50 0.80000000 0.22222222     10       3     random       NA
262  50  50 0.50000000 0.80000000     10       3     random       NA
263  50  50 0.50000000 0.50000000     10       3     random       NA
264  50  50 0.50000000 0.08333333     10       3     random       NA
265  50  50 0.22222222 0.80000000     10       3     random       NA
266  50  50 0.22222222 0.50000000     10       3     random       NA
267  50  50 0.22222222 0.08333333     10       3     random       NA
268  50 100 0.80000000 0.80000000     10       3     random       NA
269  50 100 0.80000000 0.50000000     10       3     random       NA
270  50 100 0.80000000 0.08333333     10       3     random       NA
271  50 100 0.50000000 0.80000000     10       3     random       NA
272  50 100 0.50000000 0.50000000     10       3     random       NA
273  50 100 0.50000000 0.04081633     10       3     random       NA
274  50 100 0.08333333 0.80000000     10       3     random       NA
275  50 100 0.08333333 0.50000000     10       3     random       NA
276  50 100 0.08333333 0.04081633     10       3     random       NA
277  50 250 0.80000000 0.80000000     10       3     random       NA
278  50 250 0.80000000 0.50000000     10       3     random       NA
279  50 250 0.80000000 0.04081633     10       3     random       NA
280  50 250 0.50000000 0.80000000     10       3     random       NA
281  50 250 0.50000000 0.50000000     10       3     random       NA
282  50 250 0.50000000 0.02020202     10       3     random       NA
283  50 250 0.08333333 0.80000000     10       3     random       NA
284  50 250 0.08333333 0.50000000     10       3     random       NA
285  50 250 0.08333333 0.02020202     10       3     random       NA
286 100 100 0.80000000 0.80000000     10       3     random       NA
287 100 100 0.80000000 0.50000000     10       3     random       NA
288 100 100 0.80000000 0.02020202     10       3     random       NA
289 100 100 0.50000000 0.80000000     10       3     random       NA
290 100 100 0.50000000 0.50000000     10       3     random       NA
291 100 100 0.50000000 0.22222222     10       3     random       NA
292 100 100 0.08333333 0.80000000     10       3     random       NA
293 100 100 0.08333333 0.50000000     10       3     random       NA
294 100 100 0.08333333 0.22222222     10       3     random       NA
295 100 200 0.80000000 0.80000000     10       3     random       NA
296 100 200 0.80000000 0.50000000     10       3     random       NA
297 100 200 0.80000000 0.22222222     10       3     random       NA
298 100 200 0.50000000 0.80000000     10       3     random       NA
299 100 200 0.50000000 0.50000000     10       3     random       NA
300 100 200 0.50000000 0.08333333     10       3     random       NA
301 100 200 0.04081633 0.80000000     10       3     random       NA
302 100 200 0.04081633 0.50000000     10       3     random       NA
303 100 200 0.04081633 0.08333333     10       3     random       NA
304 100 500 0.80000000 0.80000000     10       3     random       NA
305 100 500 0.80000000 0.50000000     10       3     random       NA
306 100 500 0.80000000 0.08333333     10       3     random       NA
307 100 500 0.50000000 0.80000000     10       3     random       NA
308 100 500 0.50000000 0.50000000     10       3     random       NA
309 100 500 0.50000000 0.04081633     10       3     random       NA
310 100 500 0.04081633 0.80000000     10       3     random       NA
311 100 500 0.04081633 0.50000000     10       3     random       NA
312 100 500 0.04081633 0.04081633     10       3     random       NA
313  10  10 0.80000000 0.80000000      3      10     random       NA
314  10  10 0.80000000 0.50000000      3      10     random       NA
315  10  10 0.80000000 0.04081633      3      10     random       NA
316  10  10 0.50000000 0.80000000      3      10     random       NA
317  10  10 0.50000000 0.50000000      3      10     random       NA
318  10  10 0.50000000 0.02020202      3      10     random       NA
319  10  10 0.04081633 0.80000000      3      10     random       NA
320  10  10 0.04081633 0.50000000      3      10     random       NA
321  10  10 0.04081633 0.02020202      3      10     random       NA
322  10  20 0.80000000 0.80000000      3      10     random       NA
323  10  20 0.80000000 0.50000000      3      10     random       NA
324  10  20 0.80000000 0.02020202      3      10     random       NA
325  10  20 0.50000000 0.80000000      3      10     random       NA
326  10  20 0.50000000 0.50000000      3      10     random       NA
327  10  20 0.50000000 0.22222222      3      10     random       NA
328  10  20 0.02020202 0.80000000      3      10     random       NA
329  10  20 0.02020202 0.50000000      3      10     random       NA
330  10  20 0.02020202 0.22222222      3      10     random       NA
331  10  50 0.80000000 0.80000000      3      10     random       NA
332  10  50 0.80000000 0.50000000      3      10     random       NA
333  10  50 0.80000000 0.22222222      3      10     random       NA
334  10  50 0.50000000 0.80000000      3      10     random       NA
335  10  50 0.50000000 0.50000000      3      10     random       NA
336  10  50 0.50000000 0.08333333      3      10     random       NA
337  10  50 0.02020202 0.80000000      3      10     random       NA
338  10  50 0.02020202 0.50000000      3      10     random       NA
339  10  50 0.02020202 0.08333333      3      10     random       NA
340  25  25 0.80000000 0.80000000      3      10     random       NA
341  25  25 0.80000000 0.50000000      3      10     random       NA
342  25  25 0.80000000 0.08333333      3      10     random       NA
343  25  25 0.50000000 0.80000000      3      10     random       NA
344  25  25 0.50000000 0.50000000      3      10     random       NA
345  25  25 0.50000000 0.04081633      3      10     random       NA
346  25  25 0.02020202 0.80000000      3      10     random       NA
347  25  25 0.02020202 0.50000000      3      10     random       NA
348  25  25 0.02020202 0.04081633      3      10     random       NA
349  25  50 0.80000000 0.80000000      3      10     random       NA
350  25  50 0.80000000 0.50000000      3      10     random       NA
351  25  50 0.80000000 0.04081633      3      10     random       NA
352  25  50 0.50000000 0.80000000      3      10     random       NA
353  25  50 0.50000000 0.50000000      3      10     random       NA
354  25  50 0.50000000 0.02020202      3      10     random       NA
355  25  50 0.22222222 0.80000000      3      10     random       NA
356  25  50 0.22222222 0.50000000      3      10     random       NA
357  25  50 0.22222222 0.02020202      3      10     random       NA
358  25 125 0.80000000 0.80000000      3      10     random       NA
359  25 125 0.80000000 0.50000000      3      10     random       NA
360  25 125 0.80000000 0.02020202      3      10     random       NA
361  25 125 0.50000000 0.80000000      3      10     random       NA
362  25 125 0.50000000 0.50000000      3      10     random       NA
363  25 125 0.50000000 0.22222222      3      10     random       NA
364  25 125 0.22222222 0.80000000      3      10     random       NA
365  25 125 0.22222222 0.50000000      3      10     random       NA
366  25 125 0.22222222 0.22222222      3      10     random       NA
367  50  50 0.80000000 0.80000000      3      10     random       NA
368  50  50 0.80000000 0.50000000      3      10     random       NA
369  50  50 0.80000000 0.22222222      3      10     random       NA
370  50  50 0.50000000 0.80000000      3      10     random       NA
371  50  50 0.50000000 0.50000000      3      10     random       NA
372  50  50 0.50000000 0.08333333      3      10     random       NA
373  50  50 0.22222222 0.80000000      3      10     random       NA
374  50  50 0.22222222 0.50000000      3      10     random       NA
375  50  50 0.22222222 0.08333333      3      10     random       NA
376  50 100 0.80000000 0.80000000      3      10     random       NA
377  50 100 0.80000000 0.50000000      3      10     random       NA
378  50 100 0.80000000 0.08333333      3      10     random       NA
379  50 100 0.50000000 0.80000000      3      10     random       NA
380  50 100 0.50000000 0.50000000      3      10     random       NA
381  50 100 0.50000000 0.04081633      3      10     random       NA
382  50 100 0.08333333 0.80000000      3      10     random       NA
383  50 100 0.08333333 0.50000000      3      10     random       NA
384  50 100 0.08333333 0.04081633      3      10     random       NA
385  50 250 0.80000000 0.80000000      3      10     random       NA
386  50 250 0.80000000 0.50000000      3      10     random       NA
387  50 250 0.80000000 0.04081633      3      10     random       NA
388  50 250 0.50000000 0.80000000      3      10     random       NA
389  50 250 0.50000000 0.50000000      3      10     random       NA
390  50 250 0.50000000 0.02020202      3      10     random       NA
391  50 250 0.08333333 0.80000000      3      10     random       NA
392  50 250 0.08333333 0.50000000      3      10     random       NA
393  50 250 0.08333333 0.02020202      3      10     random       NA
394 100 100 0.80000000 0.80000000      3      10     random       NA
395 100 100 0.80000000 0.50000000      3      10     random       NA
396 100 100 0.80000000 0.02020202      3      10     random       NA
397 100 100 0.50000000 0.80000000      3      10     random       NA
398 100 100 0.50000000 0.50000000      3      10     random       NA
399 100 100 0.50000000 0.22222222      3      10     random       NA
400 100 100 0.08333333 0.80000000      3      10     random       NA
401 100 100 0.08333333 0.50000000      3      10     random       NA
402 100 100 0.08333333 0.22222222      3      10     random       NA
403 100 200 0.80000000 0.80000000      3      10     random       NA
404 100 200 0.80000000 0.50000000      3      10     random       NA
405 100 200 0.80000000 0.22222222      3      10     random       NA
406 100 200 0.50000000 0.80000000      3      10     random       NA
407 100 200 0.50000000 0.50000000      3      10     random       NA
408 100 200 0.50000000 0.08333333      3      10     random       NA
409 100 200 0.04081633 0.80000000      3      10     random       NA
410 100 200 0.04081633 0.50000000      3      10     random       NA
411 100 200 0.04081633 0.08333333      3      10     random       NA
412 100 500 0.80000000 0.80000000      3      10     random       NA
413 100 500 0.80000000 0.50000000      3      10     random       NA
414 100 500 0.80000000 0.08333333      3      10     random       NA
415 100 500 0.50000000 0.80000000      3      10     random       NA
416 100 500 0.50000000 0.50000000      3      10     random       NA
417 100 500 0.50000000 0.04081633      3      10     random       NA
418 100 500 0.04081633 0.80000000      3      10     random       NA
419 100 500 0.04081633 0.50000000      3      10     random       NA
420 100 500 0.04081633 0.04081633      3      10     random       NA
421  10  10 0.80000000 0.80000000     10      10     random       NA
422  10  10 0.80000000 0.50000000     10      10     random       NA
423  10  10 0.80000000 0.04081633     10      10     random       NA
424  10  10 0.50000000 0.80000000     10      10     random       NA
425  10  10 0.50000000 0.50000000     10      10     random       NA
426  10  10 0.50000000 0.02020202     10      10     random       NA
427  10  10 0.04081633 0.80000000     10      10     random       NA
428  10  10 0.04081633 0.50000000     10      10     random       NA
429  10  10 0.04081633 0.02020202     10      10     random       NA
430  10  20 0.80000000 0.80000000     10      10     random       NA
431  10  20 0.80000000 0.50000000     10      10     random       NA
432  10  20 0.80000000 0.02020202     10      10     random       NA
433  10  20 0.50000000 0.80000000     10      10     random       NA
434  10  20 0.50000000 0.50000000     10      10     random       NA
435  10  20 0.50000000 0.22222222     10      10     random       NA
436  10  20 0.02020202 0.80000000     10      10     random       NA
437  10  20 0.02020202 0.50000000     10      10     random       NA
438  10  20 0.02020202 0.22222222     10      10     random       NA
439  10  50 0.80000000 0.80000000     10      10     random       NA
440  10  50 0.80000000 0.50000000     10      10     random       NA
441  10  50 0.80000000 0.22222222     10      10     random       NA
442  10  50 0.50000000 0.80000000     10      10     random       NA
443  10  50 0.50000000 0.50000000     10      10     random       NA
444  10  50 0.50000000 0.08333333     10      10     random       NA
445  10  50 0.02020202 0.80000000     10      10     random       NA
446  10  50 0.02020202 0.50000000     10      10     random       NA
447  10  50 0.02020202 0.08333333     10      10     random       NA
448  25  25 0.80000000 0.80000000     10      10     random       NA
449  25  25 0.80000000 0.50000000     10      10     random       NA
450  25  25 0.80000000 0.08333333     10      10     random       NA
451  25  25 0.50000000 0.80000000     10      10     random       NA
452  25  25 0.50000000 0.50000000     10      10     random       NA
453  25  25 0.50000000 0.04081633     10      10     random       NA
454  25  25 0.02020202 0.80000000     10      10     random       NA
455  25  25 0.02020202 0.50000000     10      10     random       NA
456  25  25 0.02020202 0.04081633     10      10     random       NA
457  25  50 0.80000000 0.80000000     10      10     random       NA
458  25  50 0.80000000 0.50000000     10      10     random       NA
459  25  50 0.80000000 0.04081633     10      10     random       NA
460  25  50 0.50000000 0.80000000     10      10     random       NA
461  25  50 0.50000000 0.50000000     10      10     random       NA
462  25  50 0.50000000 0.02020202     10      10     random       NA
463  25  50 0.22222222 0.80000000     10      10     random       NA
464  25  50 0.22222222 0.50000000     10      10     random       NA
465  25  50 0.22222222 0.02020202     10      10     random       NA
466  25 125 0.80000000 0.80000000     10      10     random       NA
467  25 125 0.80000000 0.50000000     10      10     random       NA
468  25 125 0.80000000 0.02020202     10      10     random       NA
469  25 125 0.50000000 0.80000000     10      10     random       NA
470  25 125 0.50000000 0.50000000     10      10     random       NA
471  25 125 0.50000000 0.22222222     10      10     random       NA
472  25 125 0.22222222 0.80000000     10      10     random       NA
473  25 125 0.22222222 0.50000000     10      10     random       NA
474  25 125 0.22222222 0.22222222     10      10     random       NA
475  50  50 0.80000000 0.80000000     10      10     random       NA
476  50  50 0.80000000 0.50000000     10      10     random       NA
477  50  50 0.80000000 0.22222222     10      10     random       NA
478  50  50 0.50000000 0.80000000     10      10     random       NA
479  50  50 0.50000000 0.50000000     10      10     random       NA
480  50  50 0.50000000 0.08333333     10      10     random       NA
481  50  50 0.22222222 0.80000000     10      10     random       NA
482  50  50 0.22222222 0.50000000     10      10     random       NA
483  50  50 0.22222222 0.08333333     10      10     random       NA
484  50 100 0.80000000 0.80000000     10      10     random       NA
485  50 100 0.80000000 0.50000000     10      10     random       NA
486  50 100 0.80000000 0.08333333     10      10     random       NA
487  50 100 0.50000000 0.80000000     10      10     random       NA
488  50 100 0.50000000 0.50000000     10      10     random       NA
489  50 100 0.50000000 0.04081633     10      10     random       NA
490  50 100 0.08333333 0.80000000     10      10     random       NA
491  50 100 0.08333333 0.50000000     10      10     random       NA
492  50 100 0.08333333 0.04081633     10      10     random       NA
493  50 250 0.80000000 0.80000000     10      10     random       NA
494  50 250 0.80000000 0.50000000     10      10     random       NA
495  50 250 0.80000000 0.04081633     10      10     random       NA
496  50 250 0.50000000 0.80000000     10      10     random       NA
497  50 250 0.50000000 0.50000000     10      10     random       NA
498  50 250 0.50000000 0.02020202     10      10     random       NA
499  50 250 0.08333333 0.80000000     10      10     random       NA
500  50 250 0.08333333 0.50000000     10      10     random       NA
501  50 250 0.08333333 0.02020202     10      10     random       NA
502 100 100 0.80000000 0.80000000     10      10     random       NA
503 100 100 0.80000000 0.50000000     10      10     random       NA
504 100 100 0.80000000 0.02020202     10      10     random       NA
505 100 100 0.50000000 0.80000000     10      10     random       NA
506 100 100 0.50000000 0.50000000     10      10     random       NA
507 100 100 0.50000000 0.22222222     10      10     random       NA
508 100 100 0.08333333 0.80000000     10      10     random       NA
509 100 100 0.08333333 0.50000000     10      10     random       NA
510 100 100 0.08333333 0.22222222     10      10     random       NA
511 100 200 0.80000000 0.80000000     10      10     random       NA
512 100 200 0.80000000 0.50000000     10      10     random       NA
513 100 200 0.80000000 0.22222222     10      10     random       NA
514 100 200 0.50000000 0.80000000     10      10     random       NA
515 100 200 0.50000000 0.50000000     10      10     random       NA
516 100 200 0.50000000 0.08333333     10      10     random       NA
517 100 200 0.04081633 0.80000000     10      10     random       NA
518 100 200 0.04081633 0.50000000     10      10     random       NA
519 100 200 0.04081633 0.08333333     10      10     random       NA
520 100 500 0.80000000 0.80000000     10      10     random       NA
521 100 500 0.80000000 0.50000000     10      10     random       NA
522 100 500 0.80000000 0.08333333     10      10     random       NA
523 100 500 0.50000000 0.80000000     10      10     random       NA
524 100 500 0.50000000 0.50000000     10      10     random       NA
525 100 500 0.50000000 0.04081633     10      10     random       NA
526 100 500 0.04081633 0.80000000     10      10     random       NA
527 100 500 0.04081633 0.50000000     10      10     random       NA
528 100 500 0.04081633 0.04081633     10      10     random       NA
> conditions_grid <- expand.grid(
+   p = rep(p, each=3),
+   n = NA,
+   true_g = NA,
+   prior_g = NA,
+   #true_rho = dgp_rho, # sparsity prior
+   #prior_g = model_g,
+   true_b = dgp_b,
+   prior_b = model_b,
+   graph_type = c("scale-free", "random", "cluster")
+   )
> conditions_grid$n  <- conditions_grid$p * c(1,2,5)
> # Define the true edge probabilities
+ row_indices3 <- rep(which(conditions_grid$graph_type == "random"), each = 3)
+ expanded_grid3 <- conditions_grid[row_indices3, ]
> prob_vector <- unlist(lapply(conditions_grid$p, function(p_val) {
+   # The vector of two probability values to be created for each p
+   c( 0.8, 0.5, 2 / (p_val - 1)) } ) )
> conditions_grid <- rbind(conditions_grid[conditions_grid$graph_type != 'random',], expanded_grid3)
+ conditions_grid$true_g <- ifelse(conditions_grid$graph_type == "random", prob_vector, 0.5)
> # Define the misspecified prior edge probabilities
+ row_indices2 <- rep(which(conditions_grid$graph_type == "random"), each = 2)
+ expanded_grid2 <- conditions_grid[row_indices2, ]
> conditions_grid <- rbind(conditions_grid[conditions_grid$graph_type != 'random',], expanded_grid2)
+ conditions_grid$prior_g <- ifelse(conditions_grid$graph_type == "random", prob_vector, 3)
> # Define the number of clusters
+ conditions_grid$clusters <- ifelse(conditions_grid$graph_type == "cluster",
+                                    pmax(2, floor(conditions_grid$p/10)), 1)
> # Fixing the row names
+ rownames(conditions_grid) <- seq(nrow(conditions_grid))
> conditions_grid
      p   n     true_g    prior_g true_b prior_b graph_type clusters
1    10  10 0.50000000 3.00000000      3       3 scale-free        1
2    10  20 0.50000000 3.00000000      3       3 scale-free        1
3    10  50 0.50000000 3.00000000      3       3 scale-free        1
4    25  25 0.50000000 3.00000000      3       3 scale-free        1
5    25  50 0.50000000 3.00000000      3       3 scale-free        1
6    25 125 0.50000000 3.00000000      3       3 scale-free        1
7    50  50 0.50000000 3.00000000      3       3 scale-free        1
8    50 100 0.50000000 3.00000000      3       3 scale-free        1
9    50 250 0.50000000 3.00000000      3       3 scale-free        1
10  100 100 0.50000000 3.00000000      3       3 scale-free        1
11  100 200 0.50000000 3.00000000      3       3 scale-free        1
12  100 500 0.50000000 3.00000000      3       3 scale-free        1
13   10  10 0.50000000 3.00000000     10       3 scale-free        1
14   10  20 0.50000000 3.00000000     10       3 scale-free        1
15   10  50 0.50000000 3.00000000     10       3 scale-free        1
16   25  25 0.50000000 3.00000000     10       3 scale-free        1
17   25  50 0.50000000 3.00000000     10       3 scale-free        1
18   25 125 0.50000000 3.00000000     10       3 scale-free        1
19   50  50 0.50000000 3.00000000     10       3 scale-free        1
20   50 100 0.50000000 3.00000000     10       3 scale-free        1
21   50 250 0.50000000 3.00000000     10       3 scale-free        1
22  100 100 0.50000000 3.00000000     10       3 scale-free        1
23  100 200 0.50000000 3.00000000     10       3 scale-free        1
24  100 500 0.50000000 3.00000000     10       3 scale-free        1
25   10  10 0.50000000 3.00000000      3      10 scale-free        1
26   10  20 0.50000000 3.00000000      3      10 scale-free        1
27   10  50 0.50000000 3.00000000      3      10 scale-free        1
28   25  25 0.50000000 3.00000000      3      10 scale-free        1
29   25  50 0.50000000 3.00000000      3      10 scale-free        1
30   25 125 0.50000000 3.00000000      3      10 scale-free        1
31   50  50 0.50000000 3.00000000      3      10 scale-free        1
32   50 100 0.50000000 3.00000000      3      10 scale-free        1
33   50 250 0.50000000 3.00000000      3      10 scale-free        1
34  100 100 0.50000000 3.00000000      3      10 scale-free        1
35  100 200 0.50000000 3.00000000      3      10 scale-free        1
36  100 500 0.50000000 3.00000000      3      10 scale-free        1
37   10  10 0.50000000 3.00000000     10      10 scale-free        1
38   10  20 0.50000000 3.00000000     10      10 scale-free        1
39   10  50 0.50000000 3.00000000     10      10 scale-free        1
40   25  25 0.50000000 3.00000000     10      10 scale-free        1
41   25  50 0.50000000 3.00000000     10      10 scale-free        1
42   25 125 0.50000000 3.00000000     10      10 scale-free        1
43   50  50 0.50000000 3.00000000     10      10 scale-free        1
44   50 100 0.50000000 3.00000000     10      10 scale-free        1
45   50 250 0.50000000 3.00000000     10      10 scale-free        1
46  100 100 0.50000000 3.00000000     10      10 scale-free        1
47  100 200 0.50000000 3.00000000     10      10 scale-free        1
48  100 500 0.50000000 3.00000000     10      10 scale-free        1
49   10  10 0.50000000 3.00000000      3       3    cluster        2
50   10  20 0.50000000 3.00000000      3       3    cluster        2
51   10  50 0.50000000 3.00000000      3       3    cluster        2
52   25  25 0.50000000 3.00000000      3       3    cluster        2
53   25  50 0.50000000 3.00000000      3       3    cluster        2
54   25 125 0.50000000 3.00000000      3       3    cluster        2
55   50  50 0.50000000 3.00000000      3       3    cluster        5
56   50 100 0.50000000 3.00000000      3       3    cluster        5
57   50 250 0.50000000 3.00000000      3       3    cluster        5
58  100 100 0.50000000 3.00000000      3       3    cluster       10
59  100 200 0.50000000 3.00000000      3       3    cluster       10
60  100 500 0.50000000 3.00000000      3       3    cluster       10
61   10  10 0.50000000 3.00000000     10       3    cluster        2
62   10  20 0.50000000 3.00000000     10       3    cluster        2
63   10  50 0.50000000 3.00000000     10       3    cluster        2
64   25  25 0.50000000 3.00000000     10       3    cluster        2
65   25  50 0.50000000 3.00000000     10       3    cluster        2
66   25 125 0.50000000 3.00000000     10       3    cluster        2
67   50  50 0.50000000 3.00000000     10       3    cluster        5
68   50 100 0.50000000 3.00000000     10       3    cluster        5
69   50 250 0.50000000 3.00000000     10       3    cluster        5
70  100 100 0.50000000 3.00000000     10       3    cluster       10
71  100 200 0.50000000 3.00000000     10       3    cluster       10
72  100 500 0.50000000 3.00000000     10       3    cluster       10
73   10  10 0.50000000 3.00000000      3      10    cluster        2
74   10  20 0.50000000 3.00000000      3      10    cluster        2
75   10  50 0.50000000 3.00000000      3      10    cluster        2
76   25  25 0.50000000 3.00000000      3      10    cluster        2
77   25  50 0.50000000 3.00000000      3      10    cluster        2
78   25 125 0.50000000 3.00000000      3      10    cluster        2
79   50  50 0.50000000 3.00000000      3      10    cluster        5
80   50 100 0.50000000 3.00000000      3      10    cluster        5
81   50 250 0.50000000 3.00000000      3      10    cluster        5
82  100 100 0.50000000 3.00000000      3      10    cluster       10
83  100 200 0.50000000 3.00000000      3      10    cluster       10
84  100 500 0.50000000 3.00000000      3      10    cluster       10
85   10  10 0.50000000 3.00000000     10      10    cluster        2
86   10  20 0.50000000 3.00000000     10      10    cluster        2
87   10  50 0.50000000 3.00000000     10      10    cluster        2
88   25  25 0.50000000 3.00000000     10      10    cluster        2
89   25  50 0.50000000 3.00000000     10      10    cluster        2
90   25 125 0.50000000 3.00000000     10      10    cluster        2
91   50  50 0.50000000 3.00000000     10      10    cluster        5
92   50 100 0.50000000 3.00000000     10      10    cluster        5
93   50 250 0.50000000 3.00000000     10      10    cluster        5
94  100 100 0.50000000 3.00000000     10      10    cluster       10
95  100 200 0.50000000 3.00000000     10      10    cluster       10
96  100 500 0.50000000 3.00000000     10      10    cluster       10
97   10  10 0.80000000 0.80000000      3       3     random        1
98   10  10 0.80000000 0.50000000      3       3     random        1
99   10  10 0.50000000 0.04081633      3       3     random        1
100  10  10 0.50000000 0.80000000      3       3     random        1
101  10  10 0.04081633 0.50000000      3       3     random        1
102  10  10 0.04081633 0.02020202      3       3     random        1
103  10  20 0.80000000 0.80000000      3       3     random        1
104  10  20 0.80000000 0.50000000      3       3     random        1
105  10  20 0.50000000 0.02020202      3       3     random        1
106  10  20 0.50000000 0.80000000      3       3     random        1
107  10  20 0.02020202 0.50000000      3       3     random        1
108  10  20 0.02020202 0.02020202      3       3     random        1
109  10  50 0.80000000 0.80000000      3       3     random        1
110  10  50 0.80000000 0.50000000      3       3     random        1
111  10  50 0.50000000 0.22222222      3       3     random        1
112  10  50 0.50000000 0.80000000      3       3     random        1
113  10  50 0.02020202 0.50000000      3       3     random        1
114  10  50 0.02020202 0.22222222      3       3     random        1
115  25  25 0.80000000 0.80000000      3       3     random        1
116  25  25 0.80000000 0.50000000      3       3     random        1
117  25  25 0.50000000 0.22222222      3       3     random        1
118  25  25 0.50000000 0.80000000      3       3     random        1
119  25  25 0.02020202 0.50000000      3       3     random        1
120  25  25 0.02020202 0.08333333      3       3     random        1
121  25  50 0.80000000 0.80000000      3       3     random        1
122  25  50 0.80000000 0.50000000      3       3     random        1
123  25  50 0.50000000 0.08333333      3       3     random        1
124  25  50 0.50000000 0.80000000      3       3     random        1
125  25  50 0.22222222 0.50000000      3       3     random        1
126  25  50 0.22222222 0.08333333      3       3     random        1
127  25 125 0.80000000 0.80000000      3       3     random        1
128  25 125 0.80000000 0.50000000      3       3     random        1
129  25 125 0.50000000 0.04081633      3       3     random        1
130  25 125 0.50000000 0.80000000      3       3     random        1
131  25 125 0.22222222 0.50000000      3       3     random        1
132  25 125 0.22222222 0.04081633      3       3     random        1
133  50  50 0.80000000 0.80000000      3       3     random        1
134  50  50 0.80000000 0.50000000      3       3     random        1
135  50  50 0.50000000 0.04081633      3       3     random        1
136  50  50 0.50000000 0.80000000      3       3     random        1
137  50  50 0.22222222 0.50000000      3       3     random        1
138  50  50 0.22222222 0.02020202      3       3     random        1
139  50 100 0.80000000 0.80000000      3       3     random        1
140  50 100 0.80000000 0.50000000      3       3     random        1
141  50 100 0.50000000 0.02020202      3       3     random        1
142  50 100 0.50000000 0.80000000      3       3     random        1
143  50 100 0.08333333 0.50000000      3       3     random        1
144  50 100 0.08333333 0.02020202      3       3     random        1
145  50 250 0.80000000 0.80000000      3       3     random        1
146  50 250 0.80000000 0.50000000      3       3     random        1
147  50 250 0.50000000 0.22222222      3       3     random        1
148  50 250 0.50000000 0.80000000      3       3     random        1
149  50 250 0.08333333 0.50000000      3       3     random        1
150  50 250 0.08333333 0.22222222      3       3     random        1
151 100 100 0.80000000 0.80000000      3       3     random        1
152 100 100 0.80000000 0.50000000      3       3     random        1
153 100 100 0.50000000 0.22222222      3       3     random        1
154 100 100 0.50000000 0.80000000      3       3     random        1
155 100 100 0.08333333 0.50000000      3       3     random        1
156 100 100 0.08333333 0.08333333      3       3     random        1
157 100 200 0.80000000 0.80000000      3       3     random        1
158 100 200 0.80000000 0.50000000      3       3     random        1
159 100 200 0.50000000 0.08333333      3       3     random        1
160 100 200 0.50000000 0.80000000      3       3     random        1
161 100 200 0.04081633 0.50000000      3       3     random        1
162 100 200 0.04081633 0.08333333      3       3     random        1
163 100 500 0.80000000 0.80000000      3       3     random        1
164 100 500 0.80000000 0.50000000      3       3     random        1
165 100 500 0.50000000 0.04081633      3       3     random        1
166 100 500 0.50000000 0.80000000      3       3     random        1
167 100 500 0.04081633 0.50000000      3       3     random        1
168 100 500 0.04081633 0.04081633      3       3     random        1
169  10  10 0.80000000 0.80000000     10       3     random        1
170  10  10 0.80000000 0.50000000     10       3     random        1
171  10  10 0.50000000 0.04081633     10       3     random        1
172  10  10 0.50000000 0.80000000     10       3     random        1
173  10  10 0.04081633 0.50000000     10       3     random        1
174  10  10 0.04081633 0.02020202     10       3     random        1
175  10  20 0.80000000 0.80000000     10       3     random        1
176  10  20 0.80000000 0.50000000     10       3     random        1
177  10  20 0.50000000 0.02020202     10       3     random        1
178  10  20 0.50000000 0.80000000     10       3     random        1
179  10  20 0.02020202 0.50000000     10       3     random        1
180  10  20 0.02020202 0.02020202     10       3     random        1
181  10  50 0.80000000 0.80000000     10       3     random        1
182  10  50 0.80000000 0.50000000     10       3     random        1
183  10  50 0.50000000 0.22222222     10       3     random        1
184  10  50 0.50000000 0.80000000     10       3     random        1
185  10  50 0.02020202 0.50000000     10       3     random        1
186  10  50 0.02020202 0.22222222     10       3     random        1
187  25  25 0.80000000 0.80000000     10       3     random        1
188  25  25 0.80000000 0.50000000     10       3     random        1
189  25  25 0.50000000 0.22222222     10       3     random        1
190  25  25 0.50000000 0.80000000     10       3     random        1
191  25  25 0.02020202 0.50000000     10       3     random        1
192  25  25 0.02020202 0.08333333     10       3     random        1
193  25  50 0.80000000 0.80000000     10       3     random        1
194  25  50 0.80000000 0.50000000     10       3     random        1
195  25  50 0.50000000 0.08333333     10       3     random        1
196  25  50 0.50000000 0.80000000     10       3     random        1
197  25  50 0.22222222 0.50000000     10       3     random        1
198  25  50 0.22222222 0.08333333     10       3     random        1
199  25 125 0.80000000 0.80000000     10       3     random        1
200  25 125 0.80000000 0.50000000     10       3     random        1
201  25 125 0.50000000 0.04081633     10       3     random        1
202  25 125 0.50000000 0.80000000     10       3     random        1
203  25 125 0.22222222 0.50000000     10       3     random        1
204  25 125 0.22222222 0.04081633     10       3     random        1
205  50  50 0.80000000 0.80000000     10       3     random        1
206  50  50 0.80000000 0.50000000     10       3     random        1
207  50  50 0.50000000 0.04081633     10       3     random        1
208  50  50 0.50000000 0.80000000     10       3     random        1
209  50  50 0.22222222 0.50000000     10       3     random        1
210  50  50 0.22222222 0.02020202     10       3     random        1
211  50 100 0.80000000 0.80000000     10       3     random        1
212  50 100 0.80000000 0.50000000     10       3     random        1
213  50 100 0.50000000 0.02020202     10       3     random        1
214  50 100 0.50000000 0.80000000     10       3     random        1
215  50 100 0.08333333 0.50000000     10       3     random        1
216  50 100 0.08333333 0.02020202     10       3     random        1
217  50 250 0.80000000 0.80000000     10       3     random        1
218  50 250 0.80000000 0.50000000     10       3     random        1
219  50 250 0.50000000 0.22222222     10       3     random        1
220  50 250 0.50000000 0.80000000     10       3     random        1
221  50 250 0.08333333 0.50000000     10       3     random        1
222  50 250 0.08333333 0.22222222     10       3     random        1
223 100 100 0.80000000 0.80000000     10       3     random        1
224 100 100 0.80000000 0.50000000     10       3     random        1
225 100 100 0.50000000 0.22222222     10       3     random        1
226 100 100 0.50000000 0.80000000     10       3     random        1
227 100 100 0.08333333 0.50000000     10       3     random        1
228 100 100 0.08333333 0.08333333     10       3     random        1
229 100 200 0.80000000 0.80000000     10       3     random        1
230 100 200 0.80000000 0.50000000     10       3     random        1
231 100 200 0.50000000 0.08333333     10       3     random        1
232 100 200 0.50000000 0.80000000     10       3     random        1
233 100 200 0.04081633 0.50000000     10       3     random        1
234 100 200 0.04081633 0.08333333     10       3     random        1
235 100 500 0.80000000 0.80000000     10       3     random        1
236 100 500 0.80000000 0.50000000     10       3     random        1
237 100 500 0.50000000 0.04081633     10       3     random        1
238 100 500 0.50000000 0.80000000     10       3     random        1
239 100 500 0.04081633 0.50000000     10       3     random        1
240 100 500 0.04081633 0.04081633     10       3     random        1
241  10  10 0.80000000 0.80000000      3      10     random        1
242  10  10 0.80000000 0.50000000      3      10     random        1
243  10  10 0.50000000 0.04081633      3      10     random        1
244  10  10 0.50000000 0.80000000      3      10     random        1
245  10  10 0.04081633 0.50000000      3      10     random        1
246  10  10 0.04081633 0.02020202      3      10     random        1
247  10  20 0.80000000 0.80000000      3      10     random        1
248  10  20 0.80000000 0.50000000      3      10     random        1
249  10  20 0.50000000 0.02020202      3      10     random        1
250  10  20 0.50000000 0.80000000      3      10     random        1
251  10  20 0.02020202 0.50000000      3      10     random        1
252  10  20 0.02020202 0.02020202      3      10     random        1
253  10  50 0.80000000 0.80000000      3      10     random        1
254  10  50 0.80000000 0.50000000      3      10     random        1
255  10  50 0.50000000 0.22222222      3      10     random        1
256  10  50 0.50000000 0.80000000      3      10     random        1
257  10  50 0.02020202 0.50000000      3      10     random        1
258  10  50 0.02020202 0.22222222      3      10     random        1
259  25  25 0.80000000 0.80000000      3      10     random        1
260  25  25 0.80000000 0.50000000      3      10     random        1
261  25  25 0.50000000 0.22222222      3      10     random        1
262  25  25 0.50000000 0.80000000      3      10     random        1
263  25  25 0.02020202 0.50000000      3      10     random        1
264  25  25 0.02020202 0.08333333      3      10     random        1
265  25  50 0.80000000 0.80000000      3      10     random        1
266  25  50 0.80000000 0.50000000      3      10     random        1
267  25  50 0.50000000 0.08333333      3      10     random        1
268  25  50 0.50000000 0.80000000      3      10     random        1
269  25  50 0.22222222 0.50000000      3      10     random        1
270  25  50 0.22222222 0.08333333      3      10     random        1
271  25 125 0.80000000 0.80000000      3      10     random        1
272  25 125 0.80000000 0.50000000      3      10     random        1
273  25 125 0.50000000 0.04081633      3      10     random        1
274  25 125 0.50000000 0.80000000      3      10     random        1
275  25 125 0.22222222 0.50000000      3      10     random        1
276  25 125 0.22222222 0.04081633      3      10     random        1
277  50  50 0.80000000 0.80000000      3      10     random        1
278  50  50 0.80000000 0.50000000      3      10     random        1
279  50  50 0.50000000 0.04081633      3      10     random        1
280  50  50 0.50000000 0.80000000      3      10     random        1
281  50  50 0.22222222 0.50000000      3      10     random        1
282  50  50 0.22222222 0.02020202      3      10     random        1
283  50 100 0.80000000 0.80000000      3      10     random        1
284  50 100 0.80000000 0.50000000      3      10     random        1
285  50 100 0.50000000 0.02020202      3      10     random        1
286  50 100 0.50000000 0.80000000      3      10     random        1
287  50 100 0.08333333 0.50000000      3      10     random        1
288  50 100 0.08333333 0.02020202      3      10     random        1
289  50 250 0.80000000 0.80000000      3      10     random        1
290  50 250 0.80000000 0.50000000      3      10     random        1
291  50 250 0.50000000 0.22222222      3      10     random        1
292  50 250 0.50000000 0.80000000      3      10     random        1
293  50 250 0.08333333 0.50000000      3      10     random        1
294  50 250 0.08333333 0.22222222      3      10     random        1
295 100 100 0.80000000 0.80000000      3      10     random        1
296 100 100 0.80000000 0.50000000      3      10     random        1
297 100 100 0.50000000 0.22222222      3      10     random        1
298 100 100 0.50000000 0.80000000      3      10     random        1
299 100 100 0.08333333 0.50000000      3      10     random        1
300 100 100 0.08333333 0.08333333      3      10     random        1
301 100 200 0.80000000 0.80000000      3      10     random        1
302 100 200 0.80000000 0.50000000      3      10     random        1
303 100 200 0.50000000 0.08333333      3      10     random        1
304 100 200 0.50000000 0.80000000      3      10     random        1
305 100 200 0.04081633 0.50000000      3      10     random        1
306 100 200 0.04081633 0.08333333      3      10     random        1
307 100 500 0.80000000 0.80000000      3      10     random        1
308 100 500 0.80000000 0.50000000      3      10     random        1
309 100 500 0.50000000 0.04081633      3      10     random        1
310 100 500 0.50000000 0.80000000      3      10     random        1
311 100 500 0.04081633 0.50000000      3      10     random        1
312 100 500 0.04081633 0.04081633      3      10     random        1
313  10  10 0.80000000 0.80000000     10      10     random        1
314  10  10 0.80000000 0.50000000     10      10     random        1
315  10  10 0.50000000 0.04081633     10      10     random        1
316  10  10 0.50000000 0.80000000     10      10     random        1
317  10  10 0.04081633 0.50000000     10      10     random        1
318  10  10 0.04081633 0.02020202     10      10     random        1
319  10  20 0.80000000 0.80000000     10      10     random        1
320  10  20 0.80000000 0.50000000     10      10     random        1
321  10  20 0.50000000 0.02020202     10      10     random        1
322  10  20 0.50000000 0.80000000     10      10     random        1
323  10  20 0.02020202 0.50000000     10      10     random        1
324  10  20 0.02020202 0.02020202     10      10     random        1
325  10  50 0.80000000 0.80000000     10      10     random        1
326  10  50 0.80000000 0.50000000     10      10     random        1
327  10  50 0.50000000 0.22222222     10      10     random        1
328  10  50 0.50000000 0.80000000     10      10     random        1
329  10  50 0.02020202 0.50000000     10      10     random        1
330  10  50 0.02020202 0.22222222     10      10     random        1
331  25  25 0.80000000 0.80000000     10      10     random        1
332  25  25 0.80000000 0.50000000     10      10     random        1
333  25  25 0.50000000 0.22222222     10      10     random        1
334  25  25 0.50000000 0.80000000     10      10     random        1
335  25  25 0.02020202 0.50000000     10      10     random        1
336  25  25 0.02020202 0.08333333     10      10     random        1
337  25  50 0.80000000 0.80000000     10      10     random        1
338  25  50 0.80000000 0.50000000     10      10     random        1
339  25  50 0.50000000 0.08333333     10      10     random        1
340  25  50 0.50000000 0.80000000     10      10     random        1
341  25  50 0.22222222 0.50000000     10      10     random        1
342  25  50 0.22222222 0.08333333     10      10     random        1
343  25 125 0.80000000 0.80000000     10      10     random        1
344  25 125 0.80000000 0.50000000     10      10     random        1
345  25 125 0.50000000 0.04081633     10      10     random        1
346  25 125 0.50000000 0.80000000     10      10     random        1
347  25 125 0.22222222 0.50000000     10      10     random        1
348  25 125 0.22222222 0.04081633     10      10     random        1
349  50  50 0.80000000 0.80000000     10      10     random        1
350  50  50 0.80000000 0.50000000     10      10     random        1
351  50  50 0.50000000 0.04081633     10      10     random        1
352  50  50 0.50000000 0.80000000     10      10     random        1
353  50  50 0.22222222 0.50000000     10      10     random        1
354  50  50 0.22222222 0.02020202     10      10     random        1
355  50 100 0.80000000 0.80000000     10      10     random        1
356  50 100 0.80000000 0.50000000     10      10     random        1
357  50 100 0.50000000 0.02020202     10      10     random        1
358  50 100 0.50000000 0.80000000     10      10     random        1
359  50 100 0.08333333 0.50000000     10      10     random        1
360  50 100 0.08333333 0.02020202     10      10     random        1
361  50 250 0.80000000 0.80000000     10      10     random        1
362  50 250 0.80000000 0.50000000     10      10     random        1
363  50 250 0.50000000 0.22222222     10      10     random        1
364  50 250 0.50000000 0.80000000     10      10     random        1
365  50 250 0.08333333 0.50000000     10      10     random        1
366  50 250 0.08333333 0.22222222     10      10     random        1
367 100 100 0.80000000 0.80000000     10      10     random        1
368 100 100 0.80000000 0.50000000     10      10     random        1
369 100 100 0.50000000 0.22222222     10      10     random        1
370 100 100 0.50000000 0.80000000     10      10     random        1
371 100 100 0.08333333 0.50000000     10      10     random        1
372 100 100 0.08333333 0.08333333     10      10     random        1
373 100 200 0.80000000 0.80000000     10      10     random        1
374 100 200 0.80000000 0.50000000     10      10     random        1
375 100 200 0.50000000 0.08333333     10      10     random        1
376 100 200 0.50000000 0.80000000     10      10     random        1
377 100 200 0.04081633 0.50000000     10      10     random        1
378 100 200 0.04081633 0.08333333     10      10     random        1
379 100 500 0.80000000 0.80000000     10      10     random        1
380 100 500 0.80000000 0.50000000     10      10     random        1
381 100 500 0.50000000 0.04081633     10      10     random        1
382 100 500 0.50000000 0.80000000     10      10     random        1
383 100 500 0.04081633 0.50000000     10      10     random        1
384 100 500 0.04081633 0.04081633     10      10     random        1
> conditions_grid <- expand.grid(
+   p = rep(p, each=3),
+   n = NA,
+   true_g = NA,
+   prior_g = NA,
+   #true_rho = dgp_rho, # sparsity prior
+   #prior_g = model_g,
+   true_b = dgp_b,
+   prior_b = model_b,
+   graph_type = c("scale-free", "random", "cluster")
+   )
> conditions_grid$n  <- conditions_grid$p * c(1,2,5)
> # Define the true edge probabilities
+ row_indices3 <- rep(which(conditions_grid$graph_type == "random"), each = 3)
+ expanded_grid3 <- conditions_grid[row_indices3, ]
> prob_vector <- unlist(lapply(conditions_grid$p, function(p_val) {
+   # The vector of two probability values to be created for each p
+   c( 0.8, 0.5, 2 / (p_val - 1)) } ) )
> conditions_grid <- rbind(conditions_grid[conditions_grid$graph_type != 'random',], expanded_grid3)
+ conditions_grid$true_g <- ifelse(conditions_grid$graph_type == "random", prob_vector, 0.5)
> # Define the misspecified prior edge probabilities
+ row_indices2 <- rep(which(conditions_grid$graph_type == "random"), each = 3)
+ expanded_grid2 <- conditions_grid[row_indices2, ]
> conditions_grid <- rbind(conditions_grid[conditions_grid$graph_type != 'random',], expanded_grid2)
+ conditions_grid$prior_g <- ifelse(conditions_grid$graph_type == "random", prob_vector, 0.5)
> # Define the number of clusters
+ conditions_grid$clusters <- ifelse(conditions_grid$graph_type == "cluster",
+                                    pmax(2, floor(conditions_grid$p/10)), 1)
> # Fixing the row names
+ rownames(conditions_grid) <- seq(nrow(conditions_grid))
> conditions_grid
      p   n     true_g    prior_g true_b prior_b graph_type clusters
1    10  10 0.50000000 0.50000000      3       3 scale-free        1
2    10  20 0.50000000 0.50000000      3       3 scale-free        1
3    10  50 0.50000000 0.50000000      3       3 scale-free        1
4    25  25 0.50000000 0.50000000      3       3 scale-free        1
5    25  50 0.50000000 0.50000000      3       3 scale-free        1
6    25 125 0.50000000 0.50000000      3       3 scale-free        1
7    50  50 0.50000000 0.50000000      3       3 scale-free        1
8    50 100 0.50000000 0.50000000      3       3 scale-free        1
9    50 250 0.50000000 0.50000000      3       3 scale-free        1
10  100 100 0.50000000 0.50000000      3       3 scale-free        1
11  100 200 0.50000000 0.50000000      3       3 scale-free        1
12  100 500 0.50000000 0.50000000      3       3 scale-free        1
13   10  10 0.50000000 0.50000000     10       3 scale-free        1
14   10  20 0.50000000 0.50000000     10       3 scale-free        1
15   10  50 0.50000000 0.50000000     10       3 scale-free        1
16   25  25 0.50000000 0.50000000     10       3 scale-free        1
17   25  50 0.50000000 0.50000000     10       3 scale-free        1
18   25 125 0.50000000 0.50000000     10       3 scale-free        1
19   50  50 0.50000000 0.50000000     10       3 scale-free        1
20   50 100 0.50000000 0.50000000     10       3 scale-free        1
21   50 250 0.50000000 0.50000000     10       3 scale-free        1
22  100 100 0.50000000 0.50000000     10       3 scale-free        1
23  100 200 0.50000000 0.50000000     10       3 scale-free        1
24  100 500 0.50000000 0.50000000     10       3 scale-free        1
25   10  10 0.50000000 0.50000000      3      10 scale-free        1
26   10  20 0.50000000 0.50000000      3      10 scale-free        1
27   10  50 0.50000000 0.50000000      3      10 scale-free        1
28   25  25 0.50000000 0.50000000      3      10 scale-free        1
29   25  50 0.50000000 0.50000000      3      10 scale-free        1
30   25 125 0.50000000 0.50000000      3      10 scale-free        1
31   50  50 0.50000000 0.50000000      3      10 scale-free        1
32   50 100 0.50000000 0.50000000      3      10 scale-free        1
33   50 250 0.50000000 0.50000000      3      10 scale-free        1
34  100 100 0.50000000 0.50000000      3      10 scale-free        1
35  100 200 0.50000000 0.50000000      3      10 scale-free        1
36  100 500 0.50000000 0.50000000      3      10 scale-free        1
37   10  10 0.50000000 0.50000000     10      10 scale-free        1
38   10  20 0.50000000 0.50000000     10      10 scale-free        1
39   10  50 0.50000000 0.50000000     10      10 scale-free        1
40   25  25 0.50000000 0.50000000     10      10 scale-free        1
41   25  50 0.50000000 0.50000000     10      10 scale-free        1
42   25 125 0.50000000 0.50000000     10      10 scale-free        1
43   50  50 0.50000000 0.50000000     10      10 scale-free        1
44   50 100 0.50000000 0.50000000     10      10 scale-free        1
45   50 250 0.50000000 0.50000000     10      10 scale-free        1
46  100 100 0.50000000 0.50000000     10      10 scale-free        1
47  100 200 0.50000000 0.50000000     10      10 scale-free        1
48  100 500 0.50000000 0.50000000     10      10 scale-free        1
49   10  10 0.50000000 0.50000000      3       3    cluster        2
50   10  20 0.50000000 0.50000000      3       3    cluster        2
51   10  50 0.50000000 0.50000000      3       3    cluster        2
52   25  25 0.50000000 0.50000000      3       3    cluster        2
53   25  50 0.50000000 0.50000000      3       3    cluster        2
54   25 125 0.50000000 0.50000000      3       3    cluster        2
55   50  50 0.50000000 0.50000000      3       3    cluster        5
56   50 100 0.50000000 0.50000000      3       3    cluster        5
57   50 250 0.50000000 0.50000000      3       3    cluster        5
58  100 100 0.50000000 0.50000000      3       3    cluster       10
59  100 200 0.50000000 0.50000000      3       3    cluster       10
60  100 500 0.50000000 0.50000000      3       3    cluster       10
61   10  10 0.50000000 0.50000000     10       3    cluster        2
62   10  20 0.50000000 0.50000000     10       3    cluster        2
63   10  50 0.50000000 0.50000000     10       3    cluster        2
64   25  25 0.50000000 0.50000000     10       3    cluster        2
65   25  50 0.50000000 0.50000000     10       3    cluster        2
66   25 125 0.50000000 0.50000000     10       3    cluster        2
67   50  50 0.50000000 0.50000000     10       3    cluster        5
68   50 100 0.50000000 0.50000000     10       3    cluster        5
69   50 250 0.50000000 0.50000000     10       3    cluster        5
70  100 100 0.50000000 0.50000000     10       3    cluster       10
71  100 200 0.50000000 0.50000000     10       3    cluster       10
72  100 500 0.50000000 0.50000000     10       3    cluster       10
73   10  10 0.50000000 0.50000000      3      10    cluster        2
74   10  20 0.50000000 0.50000000      3      10    cluster        2
75   10  50 0.50000000 0.50000000      3      10    cluster        2
76   25  25 0.50000000 0.50000000      3      10    cluster        2
77   25  50 0.50000000 0.50000000      3      10    cluster        2
78   25 125 0.50000000 0.50000000      3      10    cluster        2
79   50  50 0.50000000 0.50000000      3      10    cluster        5
80   50 100 0.50000000 0.50000000      3      10    cluster        5
81   50 250 0.50000000 0.50000000      3      10    cluster        5
82  100 100 0.50000000 0.50000000      3      10    cluster       10
83  100 200 0.50000000 0.50000000      3      10    cluster       10
84  100 500 0.50000000 0.50000000      3      10    cluster       10
85   10  10 0.50000000 0.50000000     10      10    cluster        2
86   10  20 0.50000000 0.50000000     10      10    cluster        2
87   10  50 0.50000000 0.50000000     10      10    cluster        2
88   25  25 0.50000000 0.50000000     10      10    cluster        2
89   25  50 0.50000000 0.50000000     10      10    cluster        2
90   25 125 0.50000000 0.50000000     10      10    cluster        2
91   50  50 0.50000000 0.50000000     10      10    cluster        5
92   50 100 0.50000000 0.50000000     10      10    cluster        5
93   50 250 0.50000000 0.50000000     10      10    cluster        5
94  100 100 0.50000000 0.50000000     10      10    cluster       10
95  100 200 0.50000000 0.50000000     10      10    cluster       10
96  100 500 0.50000000 0.50000000     10      10    cluster       10
97   10  10 0.80000000 0.80000000      3       3     random        1
98   10  10 0.80000000 0.50000000      3       3     random        1
99   10  10 0.80000000 0.04081633      3       3     random        1
100  10  10 0.50000000 0.80000000      3       3     random        1
101  10  10 0.50000000 0.50000000      3       3     random        1
102  10  10 0.50000000 0.02020202      3       3     random        1
103  10  10 0.04081633 0.80000000      3       3     random        1
104  10  10 0.04081633 0.50000000      3       3     random        1
105  10  10 0.04081633 0.02020202      3       3     random        1
106  10  20 0.80000000 0.80000000      3       3     random        1
107  10  20 0.80000000 0.50000000      3       3     random        1
108  10  20 0.80000000 0.02020202      3       3     random        1
109  10  20 0.50000000 0.80000000      3       3     random        1
110  10  20 0.50000000 0.50000000      3       3     random        1
111  10  20 0.50000000 0.22222222      3       3     random        1
112  10  20 0.02020202 0.80000000      3       3     random        1
113  10  20 0.02020202 0.50000000      3       3     random        1
114  10  20 0.02020202 0.22222222      3       3     random        1
115  10  50 0.80000000 0.80000000      3       3     random        1
116  10  50 0.80000000 0.50000000      3       3     random        1
117  10  50 0.80000000 0.22222222      3       3     random        1
118  10  50 0.50000000 0.80000000      3       3     random        1
119  10  50 0.50000000 0.50000000      3       3     random        1
120  10  50 0.50000000 0.08333333      3       3     random        1
121  10  50 0.02020202 0.80000000      3       3     random        1
122  10  50 0.02020202 0.50000000      3       3     random        1
123  10  50 0.02020202 0.08333333      3       3     random        1
124  25  25 0.80000000 0.80000000      3       3     random        1
125  25  25 0.80000000 0.50000000      3       3     random        1
126  25  25 0.80000000 0.08333333      3       3     random        1
127  25  25 0.50000000 0.80000000      3       3     random        1
128  25  25 0.50000000 0.50000000      3       3     random        1
129  25  25 0.50000000 0.04081633      3       3     random        1
130  25  25 0.02020202 0.80000000      3       3     random        1
131  25  25 0.02020202 0.50000000      3       3     random        1
132  25  25 0.02020202 0.04081633      3       3     random        1
133  25  50 0.80000000 0.80000000      3       3     random        1
134  25  50 0.80000000 0.50000000      3       3     random        1
135  25  50 0.80000000 0.04081633      3       3     random        1
136  25  50 0.50000000 0.80000000      3       3     random        1
137  25  50 0.50000000 0.50000000      3       3     random        1
138  25  50 0.50000000 0.02020202      3       3     random        1
139  25  50 0.22222222 0.80000000      3       3     random        1
140  25  50 0.22222222 0.50000000      3       3     random        1
141  25  50 0.22222222 0.02020202      3       3     random        1
142  25 125 0.80000000 0.80000000      3       3     random        1
143  25 125 0.80000000 0.50000000      3       3     random        1
144  25 125 0.80000000 0.02020202      3       3     random        1
145  25 125 0.50000000 0.80000000      3       3     random        1
146  25 125 0.50000000 0.50000000      3       3     random        1
147  25 125 0.50000000 0.22222222      3       3     random        1
148  25 125 0.22222222 0.80000000      3       3     random        1
149  25 125 0.22222222 0.50000000      3       3     random        1
150  25 125 0.22222222 0.22222222      3       3     random        1
151  50  50 0.80000000 0.80000000      3       3     random        1
152  50  50 0.80000000 0.50000000      3       3     random        1
153  50  50 0.80000000 0.22222222      3       3     random        1
154  50  50 0.50000000 0.80000000      3       3     random        1
155  50  50 0.50000000 0.50000000      3       3     random        1
156  50  50 0.50000000 0.08333333      3       3     random        1
157  50  50 0.22222222 0.80000000      3       3     random        1
158  50  50 0.22222222 0.50000000      3       3     random        1
159  50  50 0.22222222 0.08333333      3       3     random        1
160  50 100 0.80000000 0.80000000      3       3     random        1
161  50 100 0.80000000 0.50000000      3       3     random        1
162  50 100 0.80000000 0.08333333      3       3     random        1
163  50 100 0.50000000 0.80000000      3       3     random        1
164  50 100 0.50000000 0.50000000      3       3     random        1
165  50 100 0.50000000 0.04081633      3       3     random        1
166  50 100 0.08333333 0.80000000      3       3     random        1
167  50 100 0.08333333 0.50000000      3       3     random        1
168  50 100 0.08333333 0.04081633      3       3     random        1
169  50 250 0.80000000 0.80000000      3       3     random        1
170  50 250 0.80000000 0.50000000      3       3     random        1
171  50 250 0.80000000 0.04081633      3       3     random        1
172  50 250 0.50000000 0.80000000      3       3     random        1
173  50 250 0.50000000 0.50000000      3       3     random        1
174  50 250 0.50000000 0.02020202      3       3     random        1
175  50 250 0.08333333 0.80000000      3       3     random        1
176  50 250 0.08333333 0.50000000      3       3     random        1
177  50 250 0.08333333 0.02020202      3       3     random        1
178 100 100 0.80000000 0.80000000      3       3     random        1
179 100 100 0.80000000 0.50000000      3       3     random        1
180 100 100 0.80000000 0.02020202      3       3     random        1
181 100 100 0.50000000 0.80000000      3       3     random        1
182 100 100 0.50000000 0.50000000      3       3     random        1
183 100 100 0.50000000 0.22222222      3       3     random        1
184 100 100 0.08333333 0.80000000      3       3     random        1
185 100 100 0.08333333 0.50000000      3       3     random        1
186 100 100 0.08333333 0.22222222      3       3     random        1
187 100 200 0.80000000 0.80000000      3       3     random        1
188 100 200 0.80000000 0.50000000      3       3     random        1
189 100 200 0.80000000 0.22222222      3       3     random        1
190 100 200 0.50000000 0.80000000      3       3     random        1
191 100 200 0.50000000 0.50000000      3       3     random        1
192 100 200 0.50000000 0.08333333      3       3     random        1
193 100 200 0.04081633 0.80000000      3       3     random        1
194 100 200 0.04081633 0.50000000      3       3     random        1
195 100 200 0.04081633 0.08333333      3       3     random        1
196 100 500 0.80000000 0.80000000      3       3     random        1
197 100 500 0.80000000 0.50000000      3       3     random        1
198 100 500 0.80000000 0.08333333      3       3     random        1
199 100 500 0.50000000 0.80000000      3       3     random        1
200 100 500 0.50000000 0.50000000      3       3     random        1
201 100 500 0.50000000 0.04081633      3       3     random        1
202 100 500 0.04081633 0.80000000      3       3     random        1
203 100 500 0.04081633 0.50000000      3       3     random        1
204 100 500 0.04081633 0.04081633      3       3     random        1
205  10  10 0.80000000 0.80000000     10       3     random        1
206  10  10 0.80000000 0.50000000     10       3     random        1
207  10  10 0.80000000 0.04081633     10       3     random        1
208  10  10 0.50000000 0.80000000     10       3     random        1
209  10  10 0.50000000 0.50000000     10       3     random        1
210  10  10 0.50000000 0.02020202     10       3     random        1
211  10  10 0.04081633 0.80000000     10       3     random        1
212  10  10 0.04081633 0.50000000     10       3     random        1
213  10  10 0.04081633 0.02020202     10       3     random        1
214  10  20 0.80000000 0.80000000     10       3     random        1
215  10  20 0.80000000 0.50000000     10       3     random        1
216  10  20 0.80000000 0.02020202     10       3     random        1
217  10  20 0.50000000 0.80000000     10       3     random        1
218  10  20 0.50000000 0.50000000     10       3     random        1
219  10  20 0.50000000 0.22222222     10       3     random        1
220  10  20 0.02020202 0.80000000     10       3     random        1
221  10  20 0.02020202 0.50000000     10       3     random        1
222  10  20 0.02020202 0.22222222     10       3     random        1
223  10  50 0.80000000 0.80000000     10       3     random        1
224  10  50 0.80000000 0.50000000     10       3     random        1
225  10  50 0.80000000 0.22222222     10       3     random        1
226  10  50 0.50000000 0.80000000     10       3     random        1
227  10  50 0.50000000 0.50000000     10       3     random        1
228  10  50 0.50000000 0.08333333     10       3     random        1
229  10  50 0.02020202 0.80000000     10       3     random        1
230  10  50 0.02020202 0.50000000     10       3     random        1
231  10  50 0.02020202 0.08333333     10       3     random        1
232  25  25 0.80000000 0.80000000     10       3     random        1
233  25  25 0.80000000 0.50000000     10       3     random        1
234  25  25 0.80000000 0.08333333     10       3     random        1
235  25  25 0.50000000 0.80000000     10       3     random        1
236  25  25 0.50000000 0.50000000     10       3     random        1
237  25  25 0.50000000 0.04081633     10       3     random        1
238  25  25 0.02020202 0.80000000     10       3     random        1
239  25  25 0.02020202 0.50000000     10       3     random        1
240  25  25 0.02020202 0.04081633     10       3     random        1
241  25  50 0.80000000 0.80000000     10       3     random        1
242  25  50 0.80000000 0.50000000     10       3     random        1
243  25  50 0.80000000 0.04081633     10       3     random        1
244  25  50 0.50000000 0.80000000     10       3     random        1
245  25  50 0.50000000 0.50000000     10       3     random        1
246  25  50 0.50000000 0.02020202     10       3     random        1
247  25  50 0.22222222 0.80000000     10       3     random        1
248  25  50 0.22222222 0.50000000     10       3     random        1
249  25  50 0.22222222 0.02020202     10       3     random        1
250  25 125 0.80000000 0.80000000     10       3     random        1
251  25 125 0.80000000 0.50000000     10       3     random        1
252  25 125 0.80000000 0.02020202     10       3     random        1
253  25 125 0.50000000 0.80000000     10       3     random        1
254  25 125 0.50000000 0.50000000     10       3     random        1
255  25 125 0.50000000 0.22222222     10       3     random        1
256  25 125 0.22222222 0.80000000     10       3     random        1
257  25 125 0.22222222 0.50000000     10       3     random        1
258  25 125 0.22222222 0.22222222     10       3     random        1
259  50  50 0.80000000 0.80000000     10       3     random        1
260  50  50 0.80000000 0.50000000     10       3     random        1
261  50  50 0.80000000 0.22222222     10       3     random        1
262  50  50 0.50000000 0.80000000     10       3     random        1
263  50  50 0.50000000 0.50000000     10       3     random        1
264  50  50 0.50000000 0.08333333     10       3     random        1
265  50  50 0.22222222 0.80000000     10       3     random        1
266  50  50 0.22222222 0.50000000     10       3     random        1
267  50  50 0.22222222 0.08333333     10       3     random        1
268  50 100 0.80000000 0.80000000     10       3     random        1
269  50 100 0.80000000 0.50000000     10       3     random        1
270  50 100 0.80000000 0.08333333     10       3     random        1
271  50 100 0.50000000 0.80000000     10       3     random        1
272  50 100 0.50000000 0.50000000     10       3     random        1
273  50 100 0.50000000 0.04081633     10       3     random        1
274  50 100 0.08333333 0.80000000     10       3     random        1
275  50 100 0.08333333 0.50000000     10       3     random        1
276  50 100 0.08333333 0.04081633     10       3     random        1
277  50 250 0.80000000 0.80000000     10       3     random        1
278  50 250 0.80000000 0.50000000     10       3     random        1
279  50 250 0.80000000 0.04081633     10       3     random        1
280  50 250 0.50000000 0.80000000     10       3     random        1
281  50 250 0.50000000 0.50000000     10       3     random        1
282  50 250 0.50000000 0.02020202     10       3     random        1
283  50 250 0.08333333 0.80000000     10       3     random        1
284  50 250 0.08333333 0.50000000     10       3     random        1
285  50 250 0.08333333 0.02020202     10       3     random        1
286 100 100 0.80000000 0.80000000     10       3     random        1
287 100 100 0.80000000 0.50000000     10       3     random        1
288 100 100 0.80000000 0.02020202     10       3     random        1
289 100 100 0.50000000 0.80000000     10       3     random        1
290 100 100 0.50000000 0.50000000     10       3     random        1
291 100 100 0.50000000 0.22222222     10       3     random        1
292 100 100 0.08333333 0.80000000     10       3     random        1
293 100 100 0.08333333 0.50000000     10       3     random        1
294 100 100 0.08333333 0.22222222     10       3     random        1
295 100 200 0.80000000 0.80000000     10       3     random        1
296 100 200 0.80000000 0.50000000     10       3     random        1
297 100 200 0.80000000 0.22222222     10       3     random        1
298 100 200 0.50000000 0.80000000     10       3     random        1
299 100 200 0.50000000 0.50000000     10       3     random        1
300 100 200 0.50000000 0.08333333     10       3     random        1
301 100 200 0.04081633 0.80000000     10       3     random        1
302 100 200 0.04081633 0.50000000     10       3     random        1
303 100 200 0.04081633 0.08333333     10       3     random        1
304 100 500 0.80000000 0.80000000     10       3     random        1
305 100 500 0.80000000 0.50000000     10       3     random        1
306 100 500 0.80000000 0.08333333     10       3     random        1
307 100 500 0.50000000 0.80000000     10       3     random        1
308 100 500 0.50000000 0.50000000     10       3     random        1
309 100 500 0.50000000 0.04081633     10       3     random        1
310 100 500 0.04081633 0.80000000     10       3     random        1
311 100 500 0.04081633 0.50000000     10       3     random        1
312 100 500 0.04081633 0.04081633     10       3     random        1
313  10  10 0.80000000 0.80000000      3      10     random        1
314  10  10 0.80000000 0.50000000      3      10     random        1
315  10  10 0.80000000 0.04081633      3      10     random        1
316  10  10 0.50000000 0.80000000      3      10     random        1
317  10  10 0.50000000 0.50000000      3      10     random        1
318  10  10 0.50000000 0.02020202      3      10     random        1
319  10  10 0.04081633 0.80000000      3      10     random        1
320  10  10 0.04081633 0.50000000      3      10     random        1
321  10  10 0.04081633 0.02020202      3      10     random        1
322  10  20 0.80000000 0.80000000      3      10     random        1
323  10  20 0.80000000 0.50000000      3      10     random        1
324  10  20 0.80000000 0.02020202      3      10     random        1
325  10  20 0.50000000 0.80000000      3      10     random        1
326  10  20 0.50000000 0.50000000      3      10     random        1
327  10  20 0.50000000 0.22222222      3      10     random        1
328  10  20 0.02020202 0.80000000      3      10     random        1
329  10  20 0.02020202 0.50000000      3      10     random        1
330  10  20 0.02020202 0.22222222      3      10     random        1
331  10  50 0.80000000 0.80000000      3      10     random        1
332  10  50 0.80000000 0.50000000      3      10     random        1
333  10  50 0.80000000 0.22222222      3      10     random        1
334  10  50 0.50000000 0.80000000      3      10     random        1
335  10  50 0.50000000 0.50000000      3      10     random        1
336  10  50 0.50000000 0.08333333      3      10     random        1
337  10  50 0.02020202 0.80000000      3      10     random        1
338  10  50 0.02020202 0.50000000      3      10     random        1
339  10  50 0.02020202 0.08333333      3      10     random        1
340  25  25 0.80000000 0.80000000      3      10     random        1
341  25  25 0.80000000 0.50000000      3      10     random        1
342  25  25 0.80000000 0.08333333      3      10     random        1
343  25  25 0.50000000 0.80000000      3      10     random        1
344  25  25 0.50000000 0.50000000      3      10     random        1
345  25  25 0.50000000 0.04081633      3      10     random        1
346  25  25 0.02020202 0.80000000      3      10     random        1
347  25  25 0.02020202 0.50000000      3      10     random        1
348  25  25 0.02020202 0.04081633      3      10     random        1
349  25  50 0.80000000 0.80000000      3      10     random        1
350  25  50 0.80000000 0.50000000      3      10     random        1
351  25  50 0.80000000 0.04081633      3      10     random        1
352  25  50 0.50000000 0.80000000      3      10     random        1
353  25  50 0.50000000 0.50000000      3      10     random        1
354  25  50 0.50000000 0.02020202      3      10     random        1
355  25  50 0.22222222 0.80000000      3      10     random        1
356  25  50 0.22222222 0.50000000      3      10     random        1
357  25  50 0.22222222 0.02020202      3      10     random        1
358  25 125 0.80000000 0.80000000      3      10     random        1
359  25 125 0.80000000 0.50000000      3      10     random        1
360  25 125 0.80000000 0.02020202      3      10     random        1
361  25 125 0.50000000 0.80000000      3      10     random        1
362  25 125 0.50000000 0.50000000      3      10     random        1
363  25 125 0.50000000 0.22222222      3      10     random        1
364  25 125 0.22222222 0.80000000      3      10     random        1
365  25 125 0.22222222 0.50000000      3      10     random        1
366  25 125 0.22222222 0.22222222      3      10     random        1
367  50  50 0.80000000 0.80000000      3      10     random        1
368  50  50 0.80000000 0.50000000      3      10     random        1
369  50  50 0.80000000 0.22222222      3      10     random        1
370  50  50 0.50000000 0.80000000      3      10     random        1
371  50  50 0.50000000 0.50000000      3      10     random        1
372  50  50 0.50000000 0.08333333      3      10     random        1
373  50  50 0.22222222 0.80000000      3      10     random        1
374  50  50 0.22222222 0.50000000      3      10     random        1
375  50  50 0.22222222 0.08333333      3      10     random        1
376  50 100 0.80000000 0.80000000      3      10     random        1
377  50 100 0.80000000 0.50000000      3      10     random        1
378  50 100 0.80000000 0.08333333      3      10     random        1
379  50 100 0.50000000 0.80000000      3      10     random        1
380  50 100 0.50000000 0.50000000      3      10     random        1
381  50 100 0.50000000 0.04081633      3      10     random        1
382  50 100 0.08333333 0.80000000      3      10     random        1
383  50 100 0.08333333 0.50000000      3      10     random        1
384  50 100 0.08333333 0.04081633      3      10     random        1
385  50 250 0.80000000 0.80000000      3      10     random        1
386  50 250 0.80000000 0.50000000      3      10     random        1
387  50 250 0.80000000 0.04081633      3      10     random        1
388  50 250 0.50000000 0.80000000      3      10     random        1
389  50 250 0.50000000 0.50000000      3      10     random        1
390  50 250 0.50000000 0.02020202      3      10     random        1
391  50 250 0.08333333 0.80000000      3      10     random        1
392  50 250 0.08333333 0.50000000      3      10     random        1
393  50 250 0.08333333 0.02020202      3      10     random        1
394 100 100 0.80000000 0.80000000      3      10     random        1
395 100 100 0.80000000 0.50000000      3      10     random        1
396 100 100 0.80000000 0.02020202      3      10     random        1
397 100 100 0.50000000 0.80000000      3      10     random        1
398 100 100 0.50000000 0.50000000      3      10     random        1
399 100 100 0.50000000 0.22222222      3      10     random        1
400 100 100 0.08333333 0.80000000      3      10     random        1
401 100 100 0.08333333 0.50000000      3      10     random        1
402 100 100 0.08333333 0.22222222      3      10     random        1
403 100 200 0.80000000 0.80000000      3      10     random        1
404 100 200 0.80000000 0.50000000      3      10     random        1
405 100 200 0.80000000 0.22222222      3      10     random        1
406 100 200 0.50000000 0.80000000      3      10     random        1
407 100 200 0.50000000 0.50000000      3      10     random        1
408 100 200 0.50000000 0.08333333      3      10     random        1
409 100 200 0.04081633 0.80000000      3      10     random        1
410 100 200 0.04081633 0.50000000      3      10     random        1
411 100 200 0.04081633 0.08333333      3      10     random        1
412 100 500 0.80000000 0.80000000      3      10     random        1
413 100 500 0.80000000 0.50000000      3      10     random        1
414 100 500 0.80000000 0.08333333      3      10     random        1
415 100 500 0.50000000 0.80000000      3      10     random        1
416 100 500 0.50000000 0.50000000      3      10     random        1
417 100 500 0.50000000 0.04081633      3      10     random        1
418 100 500 0.04081633 0.80000000      3      10     random        1
419 100 500 0.04081633 0.50000000      3      10     random        1
420 100 500 0.04081633 0.04081633      3      10     random        1
421  10  10 0.80000000 0.80000000     10      10     random        1
422  10  10 0.80000000 0.50000000     10      10     random        1
423  10  10 0.80000000 0.04081633     10      10     random        1
424  10  10 0.50000000 0.80000000     10      10     random        1
425  10  10 0.50000000 0.50000000     10      10     random        1
426  10  10 0.50000000 0.02020202     10      10     random        1
427  10  10 0.04081633 0.80000000     10      10     random        1
428  10  10 0.04081633 0.50000000     10      10     random        1
429  10  10 0.04081633 0.02020202     10      10     random        1
430  10  20 0.80000000 0.80000000     10      10     random        1
431  10  20 0.80000000 0.50000000     10      10     random        1
432  10  20 0.80000000 0.02020202     10      10     random        1
433  10  20 0.50000000 0.80000000     10      10     random        1
434  10  20 0.50000000 0.50000000     10      10     random        1
435  10  20 0.50000000 0.22222222     10      10     random        1
436  10  20 0.02020202 0.80000000     10      10     random        1
437  10  20 0.02020202 0.50000000     10      10     random        1
438  10  20 0.02020202 0.22222222     10      10     random        1
439  10  50 0.80000000 0.80000000     10      10     random        1
440  10  50 0.80000000 0.50000000     10      10     random        1
441  10  50 0.80000000 0.22222222     10      10     random        1
442  10  50 0.50000000 0.80000000     10      10     random        1
443  10  50 0.50000000 0.50000000     10      10     random        1
444  10  50 0.50000000 0.08333333     10      10     random        1
445  10  50 0.02020202 0.80000000     10      10     random        1
446  10  50 0.02020202 0.50000000     10      10     random        1
447  10  50 0.02020202 0.08333333     10      10     random        1
448  25  25 0.80000000 0.80000000     10      10     random        1
449  25  25 0.80000000 0.50000000     10      10     random        1
450  25  25 0.80000000 0.08333333     10      10     random        1
451  25  25 0.50000000 0.80000000     10      10     random        1
452  25  25 0.50000000 0.50000000     10      10     random        1
453  25  25 0.50000000 0.04081633     10      10     random        1
454  25  25 0.02020202 0.80000000     10      10     random        1
455  25  25 0.02020202 0.50000000     10      10     random        1
456  25  25 0.02020202 0.04081633     10      10     random        1
457  25  50 0.80000000 0.80000000     10      10     random        1
458  25  50 0.80000000 0.50000000     10      10     random        1
459  25  50 0.80000000 0.04081633     10      10     random        1
460  25  50 0.50000000 0.80000000     10      10     random        1
461  25  50 0.50000000 0.50000000     10      10     random        1
462  25  50 0.50000000 0.02020202     10      10     random        1
463  25  50 0.22222222 0.80000000     10      10     random        1
464  25  50 0.22222222 0.50000000     10      10     random        1
465  25  50 0.22222222 0.02020202     10      10     random        1
466  25 125 0.80000000 0.80000000     10      10     random        1
467  25 125 0.80000000 0.50000000     10      10     random        1
468  25 125 0.80000000 0.02020202     10      10     random        1
469  25 125 0.50000000 0.80000000     10      10     random        1
470  25 125 0.50000000 0.50000000     10      10     random        1
471  25 125 0.50000000 0.22222222     10      10     random        1
472  25 125 0.22222222 0.80000000     10      10     random        1
473  25 125 0.22222222 0.50000000     10      10     random        1
474  25 125 0.22222222 0.22222222     10      10     random        1
475  50  50 0.80000000 0.80000000     10      10     random        1
476  50  50 0.80000000 0.50000000     10      10     random        1
477  50  50 0.80000000 0.22222222     10      10     random        1
478  50  50 0.50000000 0.80000000     10      10     random        1
479  50  50 0.50000000 0.50000000     10      10     random        1
480  50  50 0.50000000 0.08333333     10      10     random        1
481  50  50 0.22222222 0.80000000     10      10     random        1
482  50  50 0.22222222 0.50000000     10      10     random        1
483  50  50 0.22222222 0.08333333     10      10     random        1
484  50 100 0.80000000 0.80000000     10      10     random        1
485  50 100 0.80000000 0.50000000     10      10     random        1
486  50 100 0.80000000 0.08333333     10      10     random        1
487  50 100 0.50000000 0.80000000     10      10     random        1
488  50 100 0.50000000 0.50000000     10      10     random        1
489  50 100 0.50000000 0.04081633     10      10     random        1
490  50 100 0.08333333 0.80000000     10      10     random        1
491  50 100 0.08333333 0.50000000     10      10     random        1
492  50 100 0.08333333 0.04081633     10      10     random        1
493  50 250 0.80000000 0.80000000     10      10     random        1
494  50 250 0.80000000 0.50000000     10      10     random        1
495  50 250 0.80000000 0.04081633     10      10     random        1
496  50 250 0.50000000 0.80000000     10      10     random        1
497  50 250 0.50000000 0.50000000     10      10     random        1
498  50 250 0.50000000 0.02020202     10      10     random        1
499  50 250 0.08333333 0.80000000     10      10     random        1
500  50 250 0.08333333 0.50000000     10      10     random        1
501  50 250 0.08333333 0.02020202     10      10     random        1
502 100 100 0.80000000 0.80000000     10      10     random        1
503 100 100 0.80000000 0.50000000     10      10     random        1
504 100 100 0.80000000 0.02020202     10      10     random        1
505 100 100 0.50000000 0.80000000     10      10     random        1
506 100 100 0.50000000 0.50000000     10      10     random        1
507 100 100 0.50000000 0.22222222     10      10     random        1
508 100 100 0.08333333 0.80000000     10      10     random        1
509 100 100 0.08333333 0.50000000     10      10     random        1
510 100 100 0.08333333 0.22222222     10      10     random        1
511 100 200 0.80000000 0.80000000     10      10     random        1
512 100 200 0.80000000 0.50000000     10      10     random        1
513 100 200 0.80000000 0.22222222     10      10     random        1
514 100 200 0.50000000 0.80000000     10      10     random        1
515 100 200 0.50000000 0.50000000     10      10     random        1
516 100 200 0.50000000 0.08333333     10      10     random        1
517 100 200 0.04081633 0.80000000     10      10     random        1
518 100 200 0.04081633 0.50000000     10      10     random        1
519 100 200 0.04081633 0.08333333     10      10     random        1
520 100 500 0.80000000 0.80000000     10      10     random        1
521 100 500 0.80000000 0.50000000     10      10     random        1
522 100 500 0.80000000 0.08333333     10      10     random        1
523 100 500 0.50000000 0.80000000     10      10     random        1
524 100 500 0.50000000 0.50000000     10      10     random        1
525 100 500 0.50000000 0.04081633     10      10     random        1
526 100 500 0.04081633 0.80000000     10      10     random        1
527 100 500 0.04081633 0.50000000     10      10     random        1
528 100 500 0.04081633 0.04081633     10      10     random        1
> p <- c(10, 25, 50, 100)
> dgp_rho <- c(2 / (p[1] - 1), 0.5)     # Sparse vs. Dense
+ dgp_b <- c(3, p[1])              # Diffuse vs. Strict
> # Define the "Prior" parameters for model fitting
+ model_g <- c(2 / (p[1] - 1), 0.5)
+ model_b <- c(3, p[1])
> conditions_grid <- expand.grid(
+   p = rep(p, each=3),
+   n = NA,
+   true_g = NA,
+   prior_g = NA,
+   #true_rho = dgp_rho, # sparsity prior
+   #prior_g = model_g,
+   true_b = dgp_b,
+   prior_b = model_b,
+   graph_type = c("scale-free", "random", "cluster")
+   )
> conditions_grid$n  <- conditions_grid$p * c(1,2,5)
> # Define the true edge probabilities
+ row_indices3 <- rep(which(conditions_grid$graph_type == "random"), each = 3)
+ expanded_grid3 <- conditions_grid[row_indices3, ]
> prob_vector <- unlist(lapply(conditions_grid$p, function(p_val) {
+   # The vector of two probability values to be created for each p
+   c( 0.8, 0.5, 2 / (p_val - 1)) } ) )
> conditions_grid <- rbind(conditions_grid[conditions_grid$graph_type != 'random',], expanded_grid3)
+ conditions_grid$true_g <- ifelse(conditions_grid$graph_type == "random", prob_vector, 0.5)
> # Define the misspecified prior edge probabilities
+ row_indices2 <- rep(which(conditions_grid$graph_type == "random"), each = 3)
+ expanded_grid2 <- conditions_grid[row_indices2, ]
> conditions_grid <- rbind(conditions_grid[conditions_grid$graph_type != 'random',], expanded_grid2)
+ conditions_grid$prior_g <- ifelse(conditions_grid$graph_type == "random", prob_vector, 0.5)
> # Define the number of clusters
+ conditions_grid$clusters <- ifelse(conditions_grid$graph_type == "cluster",
+                                    pmax(2, floor(conditions_grid$p/10)), 1)
> # Fixing the row names
+ rownames(conditions_grid) <- seq(nrow(conditions_grid))
> conditions_grid
      p   n     true_g    prior_g true_b prior_b graph_type clusters
1    10  10 0.50000000 0.50000000      3       3 scale-free        1
2    10  20 0.50000000 0.50000000      3       3 scale-free        1
3    10  50 0.50000000 0.50000000      3       3 scale-free        1
4    25  25 0.50000000 0.50000000      3       3 scale-free        1
5    25  50 0.50000000 0.50000000      3       3 scale-free        1
6    25 125 0.50000000 0.50000000      3       3 scale-free        1
7    50  50 0.50000000 0.50000000      3       3 scale-free        1
8    50 100 0.50000000 0.50000000      3       3 scale-free        1
9    50 250 0.50000000 0.50000000      3       3 scale-free        1
10  100 100 0.50000000 0.50000000      3       3 scale-free        1
11  100 200 0.50000000 0.50000000      3       3 scale-free        1
12  100 500 0.50000000 0.50000000      3       3 scale-free        1
13   10  10 0.50000000 0.50000000     10       3 scale-free        1
14   10  20 0.50000000 0.50000000     10       3 scale-free        1
15   10  50 0.50000000 0.50000000     10       3 scale-free        1
16   25  25 0.50000000 0.50000000     10       3 scale-free        1
17   25  50 0.50000000 0.50000000     10       3 scale-free        1
18   25 125 0.50000000 0.50000000     10       3 scale-free        1
19   50  50 0.50000000 0.50000000     10       3 scale-free        1
20   50 100 0.50000000 0.50000000     10       3 scale-free        1
21   50 250 0.50000000 0.50000000     10       3 scale-free        1
22  100 100 0.50000000 0.50000000     10       3 scale-free        1
23  100 200 0.50000000 0.50000000     10       3 scale-free        1
24  100 500 0.50000000 0.50000000     10       3 scale-free        1
25   10  10 0.50000000 0.50000000      3      10 scale-free        1
26   10  20 0.50000000 0.50000000      3      10 scale-free        1
27   10  50 0.50000000 0.50000000      3      10 scale-free        1
28   25  25 0.50000000 0.50000000      3      10 scale-free        1
29   25  50 0.50000000 0.50000000      3      10 scale-free        1
30   25 125 0.50000000 0.50000000      3      10 scale-free        1
31   50  50 0.50000000 0.50000000      3      10 scale-free        1
32   50 100 0.50000000 0.50000000      3      10 scale-free        1
33   50 250 0.50000000 0.50000000      3      10 scale-free        1
34  100 100 0.50000000 0.50000000      3      10 scale-free        1
35  100 200 0.50000000 0.50000000      3      10 scale-free        1
36  100 500 0.50000000 0.50000000      3      10 scale-free        1
37   10  10 0.50000000 0.50000000     10      10 scale-free        1
38   10  20 0.50000000 0.50000000     10      10 scale-free        1
39   10  50 0.50000000 0.50000000     10      10 scale-free        1
40   25  25 0.50000000 0.50000000     10      10 scale-free        1
41   25  50 0.50000000 0.50000000     10      10 scale-free        1
42   25 125 0.50000000 0.50000000     10      10 scale-free        1
43   50  50 0.50000000 0.50000000     10      10 scale-free        1
44   50 100 0.50000000 0.50000000     10      10 scale-free        1
45   50 250 0.50000000 0.50000000     10      10 scale-free        1
46  100 100 0.50000000 0.50000000     10      10 scale-free        1
47  100 200 0.50000000 0.50000000     10      10 scale-free        1
48  100 500 0.50000000 0.50000000     10      10 scale-free        1
49   10  10 0.50000000 0.50000000      3       3    cluster        2
50   10  20 0.50000000 0.50000000      3       3    cluster        2
51   10  50 0.50000000 0.50000000      3       3    cluster        2
52   25  25 0.50000000 0.50000000      3       3    cluster        2
53   25  50 0.50000000 0.50000000      3       3    cluster        2
54   25 125 0.50000000 0.50000000      3       3    cluster        2
55   50  50 0.50000000 0.50000000      3       3    cluster        5
56   50 100 0.50000000 0.50000000      3       3    cluster        5
57   50 250 0.50000000 0.50000000      3       3    cluster        5
58  100 100 0.50000000 0.50000000      3       3    cluster       10
59  100 200 0.50000000 0.50000000      3       3    cluster       10
60  100 500 0.50000000 0.50000000      3       3    cluster       10
61   10  10 0.50000000 0.50000000     10       3    cluster        2
62   10  20 0.50000000 0.50000000     10       3    cluster        2
63   10  50 0.50000000 0.50000000     10       3    cluster        2
64   25  25 0.50000000 0.50000000     10       3    cluster        2
65   25  50 0.50000000 0.50000000     10       3    cluster        2
66   25 125 0.50000000 0.50000000     10       3    cluster        2
67   50  50 0.50000000 0.50000000     10       3    cluster        5
68   50 100 0.50000000 0.50000000     10       3    cluster        5
69   50 250 0.50000000 0.50000000     10       3    cluster        5
70  100 100 0.50000000 0.50000000     10       3    cluster       10
71  100 200 0.50000000 0.50000000     10       3    cluster       10
72  100 500 0.50000000 0.50000000     10       3    cluster       10
73   10  10 0.50000000 0.50000000      3      10    cluster        2
74   10  20 0.50000000 0.50000000      3      10    cluster        2
75   10  50 0.50000000 0.50000000      3      10    cluster        2
76   25  25 0.50000000 0.50000000      3      10    cluster        2
77   25  50 0.50000000 0.50000000      3      10    cluster        2
78   25 125 0.50000000 0.50000000      3      10    cluster        2
79   50  50 0.50000000 0.50000000      3      10    cluster        5
80   50 100 0.50000000 0.50000000      3      10    cluster        5
81   50 250 0.50000000 0.50000000      3      10    cluster        5
82  100 100 0.50000000 0.50000000      3      10    cluster       10
83  100 200 0.50000000 0.50000000      3      10    cluster       10
84  100 500 0.50000000 0.50000000      3      10    cluster       10
85   10  10 0.50000000 0.50000000     10      10    cluster        2
86   10  20 0.50000000 0.50000000     10      10    cluster        2
87   10  50 0.50000000 0.50000000     10      10    cluster        2
88   25  25 0.50000000 0.50000000     10      10    cluster        2
89   25  50 0.50000000 0.50000000     10      10    cluster        2
90   25 125 0.50000000 0.50000000     10      10    cluster        2
91   50  50 0.50000000 0.50000000     10      10    cluster        5
92   50 100 0.50000000 0.50000000     10      10    cluster        5
93   50 250 0.50000000 0.50000000     10      10    cluster        5
94  100 100 0.50000000 0.50000000     10      10    cluster       10
95  100 200 0.50000000 0.50000000     10      10    cluster       10
96  100 500 0.50000000 0.50000000     10      10    cluster       10
97   10  10 0.80000000 0.80000000      3       3     random        1
98   10  10 0.80000000 0.50000000      3       3     random        1
99   10  10 0.80000000 0.04081633      3       3     random        1
100  10  10 0.50000000 0.80000000      3       3     random        1
101  10  10 0.50000000 0.50000000      3       3     random        1
102  10  10 0.50000000 0.02020202      3       3     random        1
103  10  10 0.04081633 0.80000000      3       3     random        1
104  10  10 0.04081633 0.50000000      3       3     random        1
105  10  10 0.04081633 0.02020202      3       3     random        1
106  10  20 0.80000000 0.80000000      3       3     random        1
107  10  20 0.80000000 0.50000000      3       3     random        1
108  10  20 0.80000000 0.02020202      3       3     random        1
109  10  20 0.50000000 0.80000000      3       3     random        1
110  10  20 0.50000000 0.50000000      3       3     random        1
111  10  20 0.50000000 0.22222222      3       3     random        1
112  10  20 0.02020202 0.80000000      3       3     random        1
113  10  20 0.02020202 0.50000000      3       3     random        1
114  10  20 0.02020202 0.22222222      3       3     random        1
115  10  50 0.80000000 0.80000000      3       3     random        1
116  10  50 0.80000000 0.50000000      3       3     random        1
117  10  50 0.80000000 0.22222222      3       3     random        1
118  10  50 0.50000000 0.80000000      3       3     random        1
119  10  50 0.50000000 0.50000000      3       3     random        1
120  10  50 0.50000000 0.08333333      3       3     random        1
121  10  50 0.02020202 0.80000000      3       3     random        1
122  10  50 0.02020202 0.50000000      3       3     random        1
123  10  50 0.02020202 0.08333333      3       3     random        1
124  25  25 0.80000000 0.80000000      3       3     random        1
125  25  25 0.80000000 0.50000000      3       3     random        1
126  25  25 0.80000000 0.08333333      3       3     random        1
127  25  25 0.50000000 0.80000000      3       3     random        1
128  25  25 0.50000000 0.50000000      3       3     random        1
129  25  25 0.50000000 0.04081633      3       3     random        1
130  25  25 0.02020202 0.80000000      3       3     random        1
131  25  25 0.02020202 0.50000000      3       3     random        1
132  25  25 0.02020202 0.04081633      3       3     random        1
133  25  50 0.80000000 0.80000000      3       3     random        1
134  25  50 0.80000000 0.50000000      3       3     random        1
135  25  50 0.80000000 0.04081633      3       3     random        1
136  25  50 0.50000000 0.80000000      3       3     random        1
137  25  50 0.50000000 0.50000000      3       3     random        1
138  25  50 0.50000000 0.02020202      3       3     random        1
139  25  50 0.22222222 0.80000000      3       3     random        1
140  25  50 0.22222222 0.50000000      3       3     random        1
141  25  50 0.22222222 0.02020202      3       3     random        1
142  25 125 0.80000000 0.80000000      3       3     random        1
143  25 125 0.80000000 0.50000000      3       3     random        1
144  25 125 0.80000000 0.02020202      3       3     random        1
145  25 125 0.50000000 0.80000000      3       3     random        1
146  25 125 0.50000000 0.50000000      3       3     random        1
147  25 125 0.50000000 0.22222222      3       3     random        1
148  25 125 0.22222222 0.80000000      3       3     random        1
149  25 125 0.22222222 0.50000000      3       3     random        1
150  25 125 0.22222222 0.22222222      3       3     random        1
151  50  50 0.80000000 0.80000000      3       3     random        1
152  50  50 0.80000000 0.50000000      3       3     random        1
153  50  50 0.80000000 0.22222222      3       3     random        1
154  50  50 0.50000000 0.80000000      3       3     random        1
155  50  50 0.50000000 0.50000000      3       3     random        1
156  50  50 0.50000000 0.08333333      3       3     random        1
157  50  50 0.22222222 0.80000000      3       3     random        1
158  50  50 0.22222222 0.50000000      3       3     random        1
159  50  50 0.22222222 0.08333333      3       3     random        1
160  50 100 0.80000000 0.80000000      3       3     random        1
161  50 100 0.80000000 0.50000000      3       3     random        1
162  50 100 0.80000000 0.08333333      3       3     random        1
163  50 100 0.50000000 0.80000000      3       3     random        1
164  50 100 0.50000000 0.50000000      3       3     random        1
165  50 100 0.50000000 0.04081633      3       3     random        1
166  50 100 0.08333333 0.80000000      3       3     random        1
167  50 100 0.08333333 0.50000000      3       3     random        1
168  50 100 0.08333333 0.04081633      3       3     random        1
169  50 250 0.80000000 0.80000000      3       3     random        1
170  50 250 0.80000000 0.50000000      3       3     random        1
171  50 250 0.80000000 0.04081633      3       3     random        1
172  50 250 0.50000000 0.80000000      3       3     random        1
173  50 250 0.50000000 0.50000000      3       3     random        1
174  50 250 0.50000000 0.02020202      3       3     random        1
175  50 250 0.08333333 0.80000000      3       3     random        1
176  50 250 0.08333333 0.50000000      3       3     random        1
177  50 250 0.08333333 0.02020202      3       3     random        1
178 100 100 0.80000000 0.80000000      3       3     random        1
179 100 100 0.80000000 0.50000000      3       3     random        1
180 100 100 0.80000000 0.02020202      3       3     random        1
181 100 100 0.50000000 0.80000000      3       3     random        1
182 100 100 0.50000000 0.50000000      3       3     random        1
183 100 100 0.50000000 0.22222222      3       3     random        1
184 100 100 0.08333333 0.80000000      3       3     random        1
185 100 100 0.08333333 0.50000000      3       3     random        1
186 100 100 0.08333333 0.22222222      3       3     random        1
187 100 200 0.80000000 0.80000000      3       3     random        1
188 100 200 0.80000000 0.50000000      3       3     random        1
189 100 200 0.80000000 0.22222222      3       3     random        1
190 100 200 0.50000000 0.80000000      3       3     random        1
191 100 200 0.50000000 0.50000000      3       3     random        1
192 100 200 0.50000000 0.08333333      3       3     random        1
193 100 200 0.04081633 0.80000000      3       3     random        1
194 100 200 0.04081633 0.50000000      3       3     random        1
195 100 200 0.04081633 0.08333333      3       3     random        1
196 100 500 0.80000000 0.80000000      3       3     random        1
197 100 500 0.80000000 0.50000000      3       3     random        1
198 100 500 0.80000000 0.08333333      3       3     random        1
199 100 500 0.50000000 0.80000000      3       3     random        1
200 100 500 0.50000000 0.50000000      3       3     random        1
201 100 500 0.50000000 0.04081633      3       3     random        1
202 100 500 0.04081633 0.80000000      3       3     random        1
203 100 500 0.04081633 0.50000000      3       3     random        1
204 100 500 0.04081633 0.04081633      3       3     random        1
205  10  10 0.80000000 0.80000000     10       3     random        1
206  10  10 0.80000000 0.50000000     10       3     random        1
207  10  10 0.80000000 0.04081633     10       3     random        1
208  10  10 0.50000000 0.80000000     10       3     random        1
209  10  10 0.50000000 0.50000000     10       3     random        1
210  10  10 0.50000000 0.02020202     10       3     random        1
211  10  10 0.04081633 0.80000000     10       3     random        1
212  10  10 0.04081633 0.50000000     10       3     random        1
213  10  10 0.04081633 0.02020202     10       3     random        1
214  10  20 0.80000000 0.80000000     10       3     random        1
215  10  20 0.80000000 0.50000000     10       3     random        1
216  10  20 0.80000000 0.02020202     10       3     random        1
217  10  20 0.50000000 0.80000000     10       3     random        1
218  10  20 0.50000000 0.50000000     10       3     random        1
219  10  20 0.50000000 0.22222222     10       3     random        1
220  10  20 0.02020202 0.80000000     10       3     random        1
221  10  20 0.02020202 0.50000000     10       3     random        1
222  10  20 0.02020202 0.22222222     10       3     random        1
223  10  50 0.80000000 0.80000000     10       3     random        1
224  10  50 0.80000000 0.50000000     10       3     random        1
225  10  50 0.80000000 0.22222222     10       3     random        1
226  10  50 0.50000000 0.80000000     10       3     random        1
227  10  50 0.50000000 0.50000000     10       3     random        1
228  10  50 0.50000000 0.08333333     10       3     random        1
229  10  50 0.02020202 0.80000000     10       3     random        1
230  10  50 0.02020202 0.50000000     10       3     random        1
231  10  50 0.02020202 0.08333333     10       3     random        1
232  25  25 0.80000000 0.80000000     10       3     random        1
233  25  25 0.80000000 0.50000000     10       3     random        1
234  25  25 0.80000000 0.08333333     10       3     random        1
235  25  25 0.50000000 0.80000000     10       3     random        1
236  25  25 0.50000000 0.50000000     10       3     random        1
237  25  25 0.50000000 0.04081633     10       3     random        1
238  25  25 0.02020202 0.80000000     10       3     random        1
239  25  25 0.02020202 0.50000000     10       3     random        1
240  25  25 0.02020202 0.04081633     10       3     random        1
241  25  50 0.80000000 0.80000000     10       3     random        1
242  25  50 0.80000000 0.50000000     10       3     random        1
243  25  50 0.80000000 0.04081633     10       3     random        1
244  25  50 0.50000000 0.80000000     10       3     random        1
245  25  50 0.50000000 0.50000000     10       3     random        1
246  25  50 0.50000000 0.02020202     10       3     random        1
247  25  50 0.22222222 0.80000000     10       3     random        1
248  25  50 0.22222222 0.50000000     10       3     random        1
249  25  50 0.22222222 0.02020202     10       3     random        1
250  25 125 0.80000000 0.80000000     10       3     random        1
251  25 125 0.80000000 0.50000000     10       3     random        1
252  25 125 0.80000000 0.02020202     10       3     random        1
253  25 125 0.50000000 0.80000000     10       3     random        1
254  25 125 0.50000000 0.50000000     10       3     random        1
255  25 125 0.50000000 0.22222222     10       3     random        1
256  25 125 0.22222222 0.80000000     10       3     random        1
257  25 125 0.22222222 0.50000000     10       3     random        1
258  25 125 0.22222222 0.22222222     10       3     random        1
259  50  50 0.80000000 0.80000000     10       3     random        1
260  50  50 0.80000000 0.50000000     10       3     random        1
261  50  50 0.80000000 0.22222222     10       3     random        1
262  50  50 0.50000000 0.80000000     10       3     random        1
263  50  50 0.50000000 0.50000000     10       3     random        1
264  50  50 0.50000000 0.08333333     10       3     random        1
265  50  50 0.22222222 0.80000000     10       3     random        1
266  50  50 0.22222222 0.50000000     10       3     random        1
267  50  50 0.22222222 0.08333333     10       3     random        1
268  50 100 0.80000000 0.80000000     10       3     random        1
269  50 100 0.80000000 0.50000000     10       3     random        1
270  50 100 0.80000000 0.08333333     10       3     random        1
271  50 100 0.50000000 0.80000000     10       3     random        1
272  50 100 0.50000000 0.50000000     10       3     random        1
273  50 100 0.50000000 0.04081633     10       3     random        1
274  50 100 0.08333333 0.80000000     10       3     random        1
275  50 100 0.08333333 0.50000000     10       3     random        1
276  50 100 0.08333333 0.04081633     10       3     random        1
277  50 250 0.80000000 0.80000000     10       3     random        1
278  50 250 0.80000000 0.50000000     10       3     random        1
279  50 250 0.80000000 0.04081633     10       3     random        1
280  50 250 0.50000000 0.80000000     10       3     random        1
281  50 250 0.50000000 0.50000000     10       3     random        1
282  50 250 0.50000000 0.02020202     10       3     random        1
283  50 250 0.08333333 0.80000000     10       3     random        1
284  50 250 0.08333333 0.50000000     10       3     random        1
285  50 250 0.08333333 0.02020202     10       3     random        1
286 100 100 0.80000000 0.80000000     10       3     random        1
287 100 100 0.80000000 0.50000000     10       3     random        1
288 100 100 0.80000000 0.02020202     10       3     random        1
289 100 100 0.50000000 0.80000000     10       3     random        1
290 100 100 0.50000000 0.50000000     10       3     random        1
291 100 100 0.50000000 0.22222222     10       3     random        1
292 100 100 0.08333333 0.80000000     10       3     random        1
293 100 100 0.08333333 0.50000000     10       3     random        1
294 100 100 0.08333333 0.22222222     10       3     random        1
295 100 200 0.80000000 0.80000000     10       3     random        1
296 100 200 0.80000000 0.50000000     10       3     random        1
297 100 200 0.80000000 0.22222222     10       3     random        1
298 100 200 0.50000000 0.80000000     10       3     random        1
299 100 200 0.50000000 0.50000000     10       3     random        1
300 100 200 0.50000000 0.08333333     10       3     random        1
301 100 200 0.04081633 0.80000000     10       3     random        1
302 100 200 0.04081633 0.50000000     10       3     random        1
303 100 200 0.04081633 0.08333333     10       3     random        1
304 100 500 0.80000000 0.80000000     10       3     random        1
305 100 500 0.80000000 0.50000000     10       3     random        1
306 100 500 0.80000000 0.08333333     10       3     random        1
307 100 500 0.50000000 0.80000000     10       3     random        1
308 100 500 0.50000000 0.50000000     10       3     random        1
309 100 500 0.50000000 0.04081633     10       3     random        1
310 100 500 0.04081633 0.80000000     10       3     random        1
311 100 500 0.04081633 0.50000000     10       3     random        1
312 100 500 0.04081633 0.04081633     10       3     random        1
313  10  10 0.80000000 0.80000000      3      10     random        1
314  10  10 0.80000000 0.50000000      3      10     random        1
315  10  10 0.80000000 0.04081633      3      10     random        1
316  10  10 0.50000000 0.80000000      3      10     random        1
317  10  10 0.50000000 0.50000000      3      10     random        1
318  10  10 0.50000000 0.02020202      3      10     random        1
319  10  10 0.04081633 0.80000000      3      10     random        1
320  10  10 0.04081633 0.50000000      3      10     random        1
321  10  10 0.04081633 0.02020202      3      10     random        1
322  10  20 0.80000000 0.80000000      3      10     random        1
323  10  20 0.80000000 0.50000000      3      10     random        1
324  10  20 0.80000000 0.02020202      3      10     random        1
325  10  20 0.50000000 0.80000000      3      10     random        1
326  10  20 0.50000000 0.50000000      3      10     random        1
327  10  20 0.50000000 0.22222222      3      10     random        1
328  10  20 0.02020202 0.80000000      3      10     random        1
329  10  20 0.02020202 0.50000000      3      10     random        1
330  10  20 0.02020202 0.22222222      3      10     random        1
331  10  50 0.80000000 0.80000000      3      10     random        1
332  10  50 0.80000000 0.50000000      3      10     random        1
333  10  50 0.80000000 0.22222222      3      10     random        1
334  10  50 0.50000000 0.80000000      3      10     random        1
335  10  50 0.50000000 0.50000000      3      10     random        1
336  10  50 0.50000000 0.08333333      3      10     random        1
337  10  50 0.02020202 0.80000000      3      10     random        1
338  10  50 0.02020202 0.50000000      3      10     random        1
339  10  50 0.02020202 0.08333333      3      10     random        1
340  25  25 0.80000000 0.80000000      3      10     random        1
341  25  25 0.80000000 0.50000000      3      10     random        1
342  25  25 0.80000000 0.08333333      3      10     random        1
343  25  25 0.50000000 0.80000000      3      10     random        1
344  25  25 0.50000000 0.50000000      3      10     random        1
345  25  25 0.50000000 0.04081633      3      10     random        1
346  25  25 0.02020202 0.80000000      3      10     random        1
347  25  25 0.02020202 0.50000000      3      10     random        1
348  25  25 0.02020202 0.04081633      3      10     random        1
349  25  50 0.80000000 0.80000000      3      10     random        1
350  25  50 0.80000000 0.50000000      3      10     random        1
351  25  50 0.80000000 0.04081633      3      10     random        1
352  25  50 0.50000000 0.80000000      3      10     random        1
353  25  50 0.50000000 0.50000000      3      10     random        1
354  25  50 0.50000000 0.02020202      3      10     random        1
355  25  50 0.22222222 0.80000000      3      10     random        1
356  25  50 0.22222222 0.50000000      3      10     random        1
357  25  50 0.22222222 0.02020202      3      10     random        1
358  25 125 0.80000000 0.80000000      3      10     random        1
359  25 125 0.80000000 0.50000000      3      10     random        1
360  25 125 0.80000000 0.02020202      3      10     random        1
361  25 125 0.50000000 0.80000000      3      10     random        1
362  25 125 0.50000000 0.50000000      3      10     random        1
363  25 125 0.50000000 0.22222222      3      10     random        1
364  25 125 0.22222222 0.80000000      3      10     random        1
365  25 125 0.22222222 0.50000000      3      10     random        1
366  25 125 0.22222222 0.22222222      3      10     random        1
367  50  50 0.80000000 0.80000000      3      10     random        1
368  50  50 0.80000000 0.50000000      3      10     random        1
369  50  50 0.80000000 0.22222222      3      10     random        1
370  50  50 0.50000000 0.80000000      3      10     random        1
371  50  50 0.50000000 0.50000000      3      10     random        1
372  50  50 0.50000000 0.08333333      3      10     random        1
373  50  50 0.22222222 0.80000000      3      10     random        1
374  50  50 0.22222222 0.50000000      3      10     random        1
375  50  50 0.22222222 0.08333333      3      10     random        1
376  50 100 0.80000000 0.80000000      3      10     random        1
377  50 100 0.80000000 0.50000000      3      10     random        1
378  50 100 0.80000000 0.08333333      3      10     random        1
379  50 100 0.50000000 0.80000000      3      10     random        1
380  50 100 0.50000000 0.50000000      3      10     random        1
381  50 100 0.50000000 0.04081633      3      10     random        1
382  50 100 0.08333333 0.80000000      3      10     random        1
383  50 100 0.08333333 0.50000000      3      10     random        1
384  50 100 0.08333333 0.04081633      3      10     random        1
385  50 250 0.80000000 0.80000000      3      10     random        1
386  50 250 0.80000000 0.50000000      3      10     random        1
387  50 250 0.80000000 0.04081633      3      10     random        1
388  50 250 0.50000000 0.80000000      3      10     random        1
389  50 250 0.50000000 0.50000000      3      10     random        1
390  50 250 0.50000000 0.02020202      3      10     random        1
391  50 250 0.08333333 0.80000000      3      10     random        1
392  50 250 0.08333333 0.50000000      3      10     random        1
393  50 250 0.08333333 0.02020202      3      10     random        1
394 100 100 0.80000000 0.80000000      3      10     random        1
395 100 100 0.80000000 0.50000000      3      10     random        1
396 100 100 0.80000000 0.02020202      3      10     random        1
397 100 100 0.50000000 0.80000000      3      10     random        1
398 100 100 0.50000000 0.50000000      3      10     random        1
399 100 100 0.50000000 0.22222222      3      10     random        1
400 100 100 0.08333333 0.80000000      3      10     random        1
401 100 100 0.08333333 0.50000000      3      10     random        1
402 100 100 0.08333333 0.22222222      3      10     random        1
403 100 200 0.80000000 0.80000000      3      10     random        1
404 100 200 0.80000000 0.50000000      3      10     random        1
405 100 200 0.80000000 0.22222222      3      10     random        1
406 100 200 0.50000000 0.80000000      3      10     random        1
407 100 200 0.50000000 0.50000000      3      10     random        1
408 100 200 0.50000000 0.08333333      3      10     random        1
409 100 200 0.04081633 0.80000000      3      10     random        1
410 100 200 0.04081633 0.50000000      3      10     random        1
411 100 200 0.04081633 0.08333333      3      10     random        1
412 100 500 0.80000000 0.80000000      3      10     random        1
413 100 500 0.80000000 0.50000000      3      10     random        1
414 100 500 0.80000000 0.08333333      3      10     random        1
415 100 500 0.50000000 0.80000000      3      10     random        1
416 100 500 0.50000000 0.50000000      3      10     random        1
417 100 500 0.50000000 0.04081633      3      10     random        1
418 100 500 0.04081633 0.80000000      3      10     random        1
419 100 500 0.04081633 0.50000000      3      10     random        1
420 100 500 0.04081633 0.04081633      3      10     random        1
421  10  10 0.80000000 0.80000000     10      10     random        1
422  10  10 0.80000000 0.50000000     10      10     random        1
423  10  10 0.80000000 0.04081633     10      10     random        1
424  10  10 0.50000000 0.80000000     10      10     random        1
425  10  10 0.50000000 0.50000000     10      10     random        1
426  10  10 0.50000000 0.02020202     10      10     random        1
427  10  10 0.04081633 0.80000000     10      10     random        1
428  10  10 0.04081633 0.50000000     10      10     random        1
429  10  10 0.04081633 0.02020202     10      10     random        1
430  10  20 0.80000000 0.80000000     10      10     random        1
431  10  20 0.80000000 0.50000000     10      10     random        1
432  10  20 0.80000000 0.02020202     10      10     random        1
433  10  20 0.50000000 0.80000000     10      10     random        1
434  10  20 0.50000000 0.50000000     10      10     random        1
435  10  20 0.50000000 0.22222222     10      10     random        1
436  10  20 0.02020202 0.80000000     10      10     random        1
437  10  20 0.02020202 0.50000000     10      10     random        1
438  10  20 0.02020202 0.22222222     10      10     random        1
439  10  50 0.80000000 0.80000000     10      10     random        1
440  10  50 0.80000000 0.50000000     10      10     random        1
441  10  50 0.80000000 0.22222222     10      10     random        1
442  10  50 0.50000000 0.80000000     10      10     random        1
443  10  50 0.50000000 0.50000000     10      10     random        1
444  10  50 0.50000000 0.08333333     10      10     random        1
445  10  50 0.02020202 0.80000000     10      10     random        1
446  10  50 0.02020202 0.50000000     10      10     random        1
447  10  50 0.02020202 0.08333333     10      10     random        1
448  25  25 0.80000000 0.80000000     10      10     random        1
449  25  25 0.80000000 0.50000000     10      10     random        1
450  25  25 0.80000000 0.08333333     10      10     random        1
451  25  25 0.50000000 0.80000000     10      10     random        1
452  25  25 0.50000000 0.50000000     10      10     random        1
453  25  25 0.50000000 0.04081633     10      10     random        1
454  25  25 0.02020202 0.80000000     10      10     random        1
455  25  25 0.02020202 0.50000000     10      10     random        1
456  25  25 0.02020202 0.04081633     10      10     random        1
457  25  50 0.80000000 0.80000000     10      10     random        1
458  25  50 0.80000000 0.50000000     10      10     random        1
459  25  50 0.80000000 0.04081633     10      10     random        1
460  25  50 0.50000000 0.80000000     10      10     random        1
461  25  50 0.50000000 0.50000000     10      10     random        1
462  25  50 0.50000000 0.02020202     10      10     random        1
463  25  50 0.22222222 0.80000000     10      10     random        1
464  25  50 0.22222222 0.50000000     10      10     random        1
465  25  50 0.22222222 0.02020202     10      10     random        1
466  25 125 0.80000000 0.80000000     10      10     random        1
467  25 125 0.80000000 0.50000000     10      10     random        1
468  25 125 0.80000000 0.02020202     10      10     random        1
469  25 125 0.50000000 0.80000000     10      10     random        1
470  25 125 0.50000000 0.50000000     10      10     random        1
471  25 125 0.50000000 0.22222222     10      10     random        1
472  25 125 0.22222222 0.80000000     10      10     random        1
473  25 125 0.22222222 0.50000000     10      10     random        1
474  25 125 0.22222222 0.22222222     10      10     random        1
475  50  50 0.80000000 0.80000000     10      10     random        1
476  50  50 0.80000000 0.50000000     10      10     random        1
477  50  50 0.80000000 0.22222222     10      10     random        1
478  50  50 0.50000000 0.80000000     10      10     random        1
479  50  50 0.50000000 0.50000000     10      10     random        1
480  50  50 0.50000000 0.08333333     10      10     random        1
481  50  50 0.22222222 0.80000000     10      10     random        1
482  50  50 0.22222222 0.50000000     10      10     random        1
483  50  50 0.22222222 0.08333333     10      10     random        1
484  50 100 0.80000000 0.80000000     10      10     random        1
485  50 100 0.80000000 0.50000000     10      10     random        1
486  50 100 0.80000000 0.08333333     10      10     random        1
487  50 100 0.50000000 0.80000000     10      10     random        1
488  50 100 0.50000000 0.50000000     10      10     random        1
489  50 100 0.50000000 0.04081633     10      10     random        1
490  50 100 0.08333333 0.80000000     10      10     random        1
491  50 100 0.08333333 0.50000000     10      10     random        1
492  50 100 0.08333333 0.04081633     10      10     random        1
493  50 250 0.80000000 0.80000000     10      10     random        1
494  50 250 0.80000000 0.50000000     10      10     random        1
495  50 250 0.80000000 0.04081633     10      10     random        1
496  50 250 0.50000000 0.80000000     10      10     random        1
497  50 250 0.50000000 0.50000000     10      10     random        1
498  50 250 0.50000000 0.02020202     10      10     random        1
499  50 250 0.08333333 0.80000000     10      10     random        1
500  50 250 0.08333333 0.50000000     10      10     random        1
501  50 250 0.08333333 0.02020202     10      10     random        1
502 100 100 0.80000000 0.80000000     10      10     random        1
503 100 100 0.80000000 0.50000000     10      10     random        1
504 100 100 0.80000000 0.02020202     10      10     random        1
505 100 100 0.50000000 0.80000000     10      10     random        1
506 100 100 0.50000000 0.50000000     10      10     random        1
507 100 100 0.50000000 0.22222222     10      10     random        1
508 100 100 0.08333333 0.80000000     10      10     random        1
509 100 100 0.08333333 0.50000000     10      10     random        1
510 100 100 0.08333333 0.22222222     10      10     random        1
511 100 200 0.80000000 0.80000000     10      10     random        1
512 100 200 0.80000000 0.50000000     10      10     random        1
513 100 200 0.80000000 0.22222222     10      10     random        1
514 100 200 0.50000000 0.80000000     10      10     random        1
515 100 200 0.50000000 0.50000000     10      10     random        1
516 100 200 0.50000000 0.08333333     10      10     random        1
517 100 200 0.04081633 0.80000000     10      10     random        1
518 100 200 0.04081633 0.50000000     10      10     random        1
519 100 200 0.04081633 0.08333333     10      10     random        1
520 100 500 0.80000000 0.80000000     10      10     random        1
521 100 500 0.80000000 0.50000000     10      10     random        1
522 100 500 0.80000000 0.08333333     10      10     random        1
523 100 500 0.50000000 0.80000000     10      10     random        1
524 100 500 0.50000000 0.50000000     10      10     random        1
525 100 500 0.50000000 0.04081633     10      10     random        1
526 100 500 0.04081633 0.80000000     10      10     random        1
527 100 500 0.04081633 0.50000000     10      10     random        1
528 100 500 0.04081633 0.04081633     10      10     random        1
> params <- conditions_grid[i, ]
+   print(params)
>    p  n true_g prior_g true_b prior_b graph_type clusters
1 10 10    0.5     0.5      3       3 scale-free        1
> cat(paste("\nCondition", i, "| Repetition", rep, "of", reps, "\n"))

Condition 1 | Repetition 1 of 5 
> data  <-  bdgraph.sim(
+       p = params$p,
+       graph = params$graph_type,
+       n = params$n,
+       type = "Gaussian",
+       prob = 0.9,#params$true_g,
+       b = params$true_b,
+       class = params$clusters
+     )
> G_true <- data$G
+     K_true <- data$K
> # --- 2.2. Run the BDMCMC Algorithm ---
+     sample_bd <- bdgraph(
+       data = data$data,
+       algorithm = "bdmcmc",
+       iter = 5000,
+       g.prior = params$prior_g,
+       df.prior = params$prior_b,
+       save = TRUE
+     )
5000 MCMC sampling ... in progress: 
10%->20%->30%->40%->50%->60%->70%->80%->90%-> done> summary_bd <- summary(sample_bd)
> ??BDgraph::summary.bdgraph
> summary_bd <- summary(sample_bd, vis = FALSE)
> summary_bd
$selected_g
      [,1] [,2] [,3] [,4] [,5] [,6] [,7] [,8] [,9] [,10]
 [1,]    0    1    1    1    1    0    1    0    0     0
 [2,]    0    0    0    0    1    0    0    0    0     1
 [3,]    0    0    0    1    0    1    0    0    0     0
 [4,]    0    0    0    0    0    1    0    0    0     0
 [5,]    0    0    0    0    0    1    1    0    0     0
 [6,]    0    0    0    0    0    0    0    0    0     1
 [7,]    0    0    0    0    0    0    0    0    0     0
 [8,]    0    0    0    0    0    0    0    0    0     0
 [9,]    0    0    0    0    0    0    0    0    0     0
[10,]    0    0    0    0    0    0    0    0    0     0

$p_links
      [,1] [,2] [,3] [,4] [,5] [,6] [,7] [,8] [,9] [,10]
 [1,]    0 0.82 0.65 1.00 0.54 0.35 0.58 0.50 0.37  0.48
 [2,]    0 0.00 0.50 0.37 0.54 0.32 0.27 0.30 0.32  0.61
 [3,]    0 0.00 0.00 0.72 0.41 0.72 0.29 0.35 0.44  0.49
 [4,]    0 0.00 0.00 0.00 0.35 0.53 0.38 0.37 0.29  0.40
 [5,]    0 0.00 0.00 0.00 0.00 0.51 0.79 0.13 0.14  0.42
 [6,]    0 0.00 0.00 0.00 0.00 0.00 0.29 0.41 0.28  0.93
 [7,]    0 0.00 0.00 0.00 0.00 0.00 0.00 0.19 0.22  0.34
 [8,]    0 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.26  0.18
 [9,]    0 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00  0.33
[10,]    0 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00  0.00

$K_hat
       [,1]  [,2]  [,3]  [,4]  [,5]  [,6]  [,7]  [,8]  [,9] [,10]
 [1,] 11.19 -2.94  0.79 -5.38 -0.72 -0.12  0.73  0.38 -0.24  0.42
 [2,] -2.94  4.93 -0.23 -0.80  0.77  0.29 -0.08 -0.03 -0.10  0.84
 [3,]  0.79 -0.23  5.36  1.41  0.27 -1.68 -0.16 -0.20 -0.41  0.63
 [4,] -5.38 -0.80  1.41  6.86 -0.23  0.44  0.07 -0.12 -0.11  0.36
 [5,] -0.72  0.77  0.27 -0.23  2.50 -0.55  0.84  0.01 -0.01 -0.38
 [6,] -0.12  0.29 -1.68  0.44 -0.55  6.70  0.09 -0.38  0.00 -2.77
 [7,]  0.73 -0.08 -0.16  0.07  0.84  0.09  2.32 -0.02 -0.02 -0.08
 [8,]  0.38 -0.03 -0.20 -0.12  0.01 -0.38 -0.02  2.39 -0.13  0.03
 [9,] -0.24 -0.10 -0.41 -0.11 -0.01  0.00 -0.02 -0.13  1.84  0.28
[10,]  0.42  0.84  0.63  0.36 -0.38 -2.77 -0.08  0.03  0.28  4.61

> summary_bd <- summary(sample_bd, round = 3, vis = FALSE)
> summary_bd
$selected_g
      [,1] [,2] [,3] [,4] [,5] [,6] [,7] [,8] [,9] [,10]
 [1,]    0    1    1    1    1    0    1    0    0     0
 [2,]    0    0    0    0    1    0    0    0    0     1
 [3,]    0    0    0    1    0    1    0    0    0     0
 [4,]    0    0    0    0    0    1    0    0    0     0
 [5,]    0    0    0    0    0    1    1    0    0     0
 [6,]    0    0    0    0    0    0    0    0    0     1
 [7,]    0    0    0    0    0    0    0    0    0     0
 [8,]    0    0    0    0    0    0    0    0    0     0
 [9,]    0    0    0    0    0    0    0    0    0     0
[10,]    0    0    0    0    0    0    0    0    0     0

$p_links
      [,1] [,2] [,3] [,4] [,5] [,6] [,7] [,8] [,9] [,10]
 [1,]    0 0.82 0.65 1.00 0.54 0.35 0.58 0.50 0.37  0.48
 [2,]    0 0.00 0.50 0.37 0.54 0.32 0.27 0.30 0.32  0.61
 [3,]    0 0.00 0.00 0.72 0.41 0.72 0.29 0.35 0.44  0.49
 [4,]    0 0.00 0.00 0.00 0.35 0.53 0.38 0.37 0.29  0.40
 [5,]    0 0.00 0.00 0.00 0.00 0.51 0.79 0.13 0.14  0.42
 [6,]    0 0.00 0.00 0.00 0.00 0.00 0.29 0.41 0.28  0.93
 [7,]    0 0.00 0.00 0.00 0.00 0.00 0.00 0.19 0.22  0.34
 [8,]    0 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.26  0.18
 [9,]    0 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00  0.33
[10,]    0 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00  0.00

$K_hat
        [,1]   [,2]   [,3]   [,4]   [,5]   [,6]   [,7]   [,8]   [,9]  [,10]
 [1,] 11.188 -2.935  0.788 -5.375 -0.723 -0.123  0.732  0.382 -0.242  0.420
 [2,] -2.935  4.927 -0.235 -0.796  0.772  0.293 -0.078 -0.030 -0.103  0.843
 [3,]  0.788 -0.235  5.358  1.405  0.268 -1.677 -0.161 -0.197 -0.414  0.630
 [4,] -5.375 -0.796  1.405  6.858 -0.234  0.440  0.066 -0.119 -0.111  0.356
 [5,] -0.723  0.772  0.268 -0.234  2.496 -0.551  0.840  0.015 -0.015 -0.375
 [6,] -0.123  0.293 -1.677  0.440 -0.551  6.703  0.086 -0.379  0.002 -2.767
 [7,]  0.732 -0.078 -0.161  0.066  0.840  0.086  2.316 -0.018 -0.025 -0.079
 [8,]  0.382 -0.030 -0.197 -0.119  0.015 -0.379 -0.018  2.391 -0.126  0.031
 [9,] -0.242 -0.103 -0.414 -0.111 -0.015  0.002 -0.025 -0.126  1.839  0.285
[10,]  0.420  0.843  0.630  0.356 -0.375 -2.767 -0.079  0.031  0.285  4.608

> # Extract estimated G and K
+     pip_edge <- summary_bd$p_links
+     G_est <- summary_bd$selected_g
+     K_est <- summary_bd$K_hat
> # -- 3.1. Graph Structure Recovery Metrics --
+     true_vec <- G_true[upper.tri(G_true)]
+     est_vec <- G_est[upper.tri(G_est)]
+     prob_vec <- pip_edge[upper.tri(pip_edge)]
> TP <- sum(est_vec == 1 & true_vec == 1)
+     FP <- sum(est_vec == 1 & true_vec == 0)
+     TN <- sum(est_vec == 0 & true_vec == 0)
+     FN <- sum(est_vec == 0 & true_vec == 1)
> sensitivity <- ifelse((TP + FN) == 0, 0, TP / (TP + FN))
+     specificity <- ifelse((TN + FP) == 0, 0, TN / (TN + FP))
+     precision   <- ifelse((TP + FP) == 0, 0, TP / (TP + FP))
+     f1_score    <- ifelse((precision + sensitivity) == 0, 0,
+                           2 * (precision * sensitivity) / (precision + sensitivity))
> roc_obj <- BDgraph::roc(pred = sample_bd, actual = data, auc = TRUE)
+     auc_val <- as.numeric(roc_obj$auc)
> > # -- 3.2. Precision Matrix Estimation Metrics --
+     diff_K <- K_est - K_true
+     frobenius_norm <- norm(diff_K, type = "F")
+     spectral_norm  <- norm(diff_K, type = "2")
+     rmse <- sqrt(mean(diff_K^2))
> # -- 3.3. Node Strength Difference Metric --
+     strength_true <- get_strength(G_true, K_true)
+     strength_est  <- get_strength(G_est, K_est)
+     strength_mae <- mean(abs(strength_est - strength_true))
> # -- 3.4. Magnitude of Probability Metrics (NEW) --
+     p_plus <- ifelse(sum(true_vec) == 0, 0, mean(prob_vec[true_vec == 1]))
+     p_minus <- ifelse(sum(true_vec == 0) == 0, 0, mean(prob_vec[true_vec == 0]))
> # --- 4. STORE RESULTS ---
+     current_run_results <- data.frame(
+       condition_id = i, rep = rep, p = params$p,
+       n = params$n, graph_type = params$graph_type, g_prior = params$g_prior,
+       sensitivity = sensitivity, specificity = specificity,
+       precision = precision, f1_score = f1_score, auc = auc_val,
+       p_plus = p_plus, p_minus = p_minus,
+       frobenius_norm = frobenius_norm, spectral_norm = spectral_norm,
+       rmse = rmse, strength_mae = strength_mae
+     )
Error in data.frame(condition_id = i, rep = rep, p = params$p, n = params$n,  : 
  arguments imply differing number of rows: 1, 0
> results_df <- rbind(results_df, current_run_results)
Error: object 'current_run_results' not found
> filename <- paste0("out/results_", i, ".rds")
> if (i %% 24 == 0) saveRDS(filename)
> params
   p  n true_g prior_g true_b prior_b graph_type clusters
1 10 10    0.5     0.5      3       3 scale-free        1
> # --- 4. STORE RESULTS ---
+     current_run_results <- data.frame(
+       condition_id = i, rep = rep, p = params$p,
+       n = params$n, graph_type = params$graph_type,
+       g_prior = params$prior_g, g_true = params$true_g,
+       b_prior = params$prior_b, b_true = params$true_b,
+       size = params$clusters,
+       sensitivity = sensitivity, specificity = specificity,
+       precision = precision, f1_score = f1_score, auc = auc_val,
+       p_plus = p_plus, p_minus = p_minus,
+       frobenius_norm = frobenius_norm, spectral_norm = spectral_norm,
+       rmse = rmse, strength_mae = strength_mae
+     )
> results_df <- rbind(results_df, current_run_results)
+     filename <- paste0("out/results_", i, ".rds")
+     if (i %% 24 == 0) saveRDS(filename)
> results_df
  condition_id rep  p  n graph_type g_prior g_true b_prior b_true size sensitivity specificity precision  f1_score       auc    p_plus
1            1   1 10 10 scale-free     0.5    0.5       3      3    1   0.4444444        0.75 0.3076923 0.3636364 0.6759259 0.5477778
    p_minus frobenius_norm spectral_norm     rmse strength_mae
1 0.4097222       10.94948      8.133511 1.094948    0.4285902
> pip_edge
      [,1] [,2] [,3] [,4] [,5] [,6] [,7] [,8] [,9] [,10]
 [1,]    0 0.82 0.65 1.00 0.54 0.35 0.58 0.50 0.37  0.48
 [2,]    0 0.00 0.50 0.37 0.54 0.32 0.27 0.30 0.32  0.61
 [3,]    0 0.00 0.00 0.72 0.41 0.72 0.29 0.35 0.44  0.49
 [4,]    0 0.00 0.00 0.00 0.35 0.53 0.38 0.37 0.29  0.40
 [5,]    0 0.00 0.00 0.00 0.00 0.51 0.79 0.13 0.14  0.42
 [6,]    0 0.00 0.00 0.00 0.00 0.00 0.29 0.41 0.28  0.93
 [7,]    0 0.00 0.00 0.00 0.00 0.00 0.00 0.19 0.22  0.34
 [8,]    0 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.26  0.18
 [9,]    0 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00  0.33
[10,]    0 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00  0.00
> 
> str(summary_bd)
List of 3
 $ selected_g: num [1:10, 1:10] 0 0 0 0 0 0 0 0 0 0 ...
  ..- attr(*, "dimnames")=List of 2
  .. ..$ : NULL
  .. ..$ : NULL
 $ p_links   : num [1:10, 1:10] 0 0 0 0 0 0 0 0 0 0 ...
  ..- attr(*, "dimnames")=List of 2
  .. ..$ : NULL
  .. ..$ : NULL
 $ K_hat     : num [1:10, 1:10] 11.188 -2.935 0.788 -5.375 -0.723 ...
  ..- attr(*, "dimnames")=List of 2
  .. ..$ : NULL
  .. ..$ : NULL
> sample_bd$K
            [,1]        [,2]       [,3]        [,4]        [,5]         [,6]        [,7]        [,8]         [,9]       [,10]
 [1,] 11.1876973 -2.93514724  0.7884364 -5.37539785 -0.72263167 -0.122968299  0.73247029  0.38160639 -0.241738367  0.42022513
 [2,] -2.9351472  4.92712772 -0.2349511 -0.79582217  0.77152906  0.292971673 -0.07813233 -0.03012103 -0.102981965  0.84275042
 [3,]  0.7884364 -0.23495106  5.3583013  1.40541060  0.26786219 -1.676500557 -0.16137630 -0.19684119 -0.413842288  0.62989690
 [4,] -5.3753978 -0.79582217  1.4054106  6.85793805 -0.23352746  0.439951121  0.06550795 -0.11919575 -0.111161185  0.35575327
 [5,] -0.7226317  0.77152906  0.2678622 -0.23352746  2.49643394 -0.550576933  0.84044900  0.01492989 -0.014556223 -0.37525286
 [6,] -0.1229683  0.29297167 -1.6765006  0.43995112 -0.55057693  6.702944222  0.08629218 -0.37947118  0.002146578 -2.76685456
 [7,]  0.7324703 -0.07813233 -0.1613763  0.06550795  0.84044900  0.086292176  2.31559343 -0.01822144 -0.024712203 -0.07904732
 [8,]  0.3816064 -0.03012103 -0.1968412 -0.11919575  0.01492989 -0.379471180 -0.01822144  2.39124972 -0.125544487  0.03099639
 [9,] -0.2417384 -0.10298196 -0.4138423 -0.11116118 -0.01455622  0.002146578 -0.02471220 -0.12554449  1.839135907  0.28454274
[10,]  0.4202251  0.84275042  0.6298969  0.35575327 -0.37525286 -2.766854564 -0.07904732  0.03099639  0.284542743  4.60818103
> sample_bd$K_hat
            [,1]        [,2]       [,3]        [,4]        [,5]         [,6]        [,7]        [,8]         [,9]       [,10]
 [1,] 11.1876973 -2.93514724  0.7884364 -5.37539785 -0.72263167 -0.122968299  0.73247029  0.38160639 -0.241738367  0.42022513
 [2,] -2.9351472  4.92712772 -0.2349511 -0.79582217  0.77152906  0.292971673 -0.07813233 -0.03012103 -0.102981965  0.84275042
 [3,]  0.7884364 -0.23495106  5.3583013  1.40541060  0.26786219 -1.676500557 -0.16137630 -0.19684119 -0.413842288  0.62989690
 [4,] -5.3753978 -0.79582217  1.4054106  6.85793805 -0.23352746  0.439951121  0.06550795 -0.11919575 -0.111161185  0.35575327
 [5,] -0.7226317  0.77152906  0.2678622 -0.23352746  2.49643394 -0.550576933  0.84044900  0.01492989 -0.014556223 -0.37525286
 [6,] -0.1229683  0.29297167 -1.6765006  0.43995112 -0.55057693  6.702944222  0.08629218 -0.37947118  0.002146578 -2.76685456
 [7,]  0.7324703 -0.07813233 -0.1613763  0.06550795  0.84044900  0.086292176  2.31559343 -0.01822144 -0.024712203 -0.07904732
 [8,]  0.3816064 -0.03012103 -0.1968412 -0.11919575  0.01492989 -0.379471180 -0.01822144  2.39124972 -0.125544487  0.03099639
 [9,] -0.2417384 -0.10298196 -0.4138423 -0.11116118 -0.01455622  0.002146578 -0.02471220 -0.12554449  1.839135907  0.28454274
[10,]  0.4202251  0.84275042  0.6298969  0.35575327 -0.37525286 -2.766854564 -0.07904732  0.03099639  0.284542743  4.60818103
> K_est
        [,1]   [,2]   [,3]   [,4]   [,5]   [,6]   [,7]   [,8]   [,9]  [,10]
 [1,] 11.188 -2.935  0.788 -5.375 -0.723 -0.123  0.732  0.382 -0.242  0.420
 [2,] -2.935  4.927 -0.235 -0.796  0.772  0.293 -0.078 -0.030 -0.103  0.843
 [3,]  0.788 -0.235  5.358  1.405  0.268 -1.677 -0.161 -0.197 -0.414  0.630
 [4,] -5.375 -0.796  1.405  6.858 -0.234  0.440  0.066 -0.119 -0.111  0.356
 [5,] -0.723  0.772  0.268 -0.234  2.496 -0.551  0.840  0.015 -0.015 -0.375
 [6,] -0.123  0.293 -1.677  0.440 -0.551  6.703  0.086 -0.379  0.002 -2.767
 [7,]  0.732 -0.078 -0.161  0.066  0.840  0.086  2.316 -0.018 -0.025 -0.079
 [8,]  0.382 -0.030 -0.197 -0.119  0.015 -0.379 -0.018  2.391 -0.126  0.031
 [9,] -0.242 -0.103 -0.414 -0.111 -0.015  0.002 -0.025 -0.126  1.839  0.285
[10,]  0.420  0.843  0.630  0.356 -0.375 -2.767 -0.079  0.031  0.285  4.608
> sample_bd$G
NULL
> str(sample_bd)
List of 9
 $ sample_graphs: chr [1:2407] "111100000110111100110100001001110101100011000" "111100000110111100111100001001110101100011000" "111100000110111100111100001001100101100011000" "111100000110111100111100001001110100100011000" ...
 $ graph_weights: num [1:2407] 0.0587 0.1184 0.0694 0.0419 0.0461 ...
 $ K_hat        : num [1:10, 1:10] 11.188 -2.935 0.788 -5.375 -0.723 ...
  ..- attr(*, "dimnames")=List of 2
  .. ..$ : NULL
  .. ..$ : NULL
 $ all_graphs   : num [1:2500] 1 2 3 2 4 5 6 7 8 9 ...
 $ all_weights  : num [1:2500] 0.0587 0.0508 0.0694 0.0676 0.0419 ...
 $ last_graph   : int [1:10, 1:10] 0 1 1 1 1 0 1 0 1 0 ...
  ..- attr(*, "dimnames")=List of 2
  .. ..$ : NULL
  .. ..$ : NULL
 $ last_K       : num [1:10, 1:10] 7.971 -0.807 2.528 -3.505 -1.272 ...
 $ data         : num [1:10, 1:10] -0.374 0.784 0.133 -0.963 0.773 ...
 $ method       : chr "ggm"
 - attr(*, "class")= chr "bdgraph"
> G_est
      [,1] [,2] [,3] [,4] [,5] [,6] [,7] [,8] [,9] [,10]
 [1,]    0    1    1    1    1    0    1    0    0     0
 [2,]    0    0    0    0    1    0    0    0    0     1
 [3,]    0    0    0    1    0    1    0    0    0     0
 [4,]    0    0    0    0    0    1    0    0    0     0
 [5,]    0    0    0    0    0    1    1    0    0     0
 [6,]    0    0    0    0    0    0    0    0    0     1
 [7,]    0    0    0    0    0    0    0    0    0     0
 [8,]    0    0    0    0    0    0    0    0    0     0
 [9,]    0    0    0    0    0    0    0    0    0     0
[10,]    0    0    0    0    0    0    0    0    0     0
> BDgraph::roc(pred = sample_bd, actual = data, auc = TRUE)

Call:
roc.default(response = actual, predictor = pred, levels = c(0,     1), quiet = quiet, smooth = smooth, plot = plot)

Data: pred in 36 controls (actual 0) < 9 cases (actual 1).
Area under the curve: 0.6759
> library(dplyr)

Attaching package: ‘dplyr’

The following object is masked from ‘package:BDgraph’:

    select

The following objects are masked from ‘package:stats’:

    filter, lag

The following objects are masked from ‘package:base’:

    intersect, setdiff, setequal, union

> p_levels     <- c(25, 100)
> n_mult_levels<- c(1, 5) # Multiplier for p, gives n=p and n=5p
> type_levels  <- c("scale-free", "random", "cluster")
> base_grid <- expand.grid(
+ p = p_levels,
+ n_multiplier = n_mult_levels,
+ graph_type = type_levels
+ )
> base_grid
     p n_multiplier graph_type
1   25            1 scale-free
2  100            1 scale-free
3   25            5 scale-free
4  100            5 scale-free
5   25            1     random
6  100            1     random
7   25            5     random
8  100            5     random
9   25            1    cluster
10 100            1    cluster
11  25            5    cluster
12 100            5    cluster
> dgp_grid <- expand.grid(
+ true_g = c(0.1, 0.5), # Sparse vs. Dense truth for 'random' and 'cluster'
+ true_b = c(3, NA)     # Using p requires p to be defined, so we do it later
+ )
> model_grid <- expand.grid(
+ prior_g = c(0.1, 0.5), # Sparse vs. Dense prior
+ prior_b = c(3, NA)
+ )
> conditions_grid <- tidyr::crossing(base_grid, dgp_grid, model_grid)
> conditions_grid
# A tibble: 192 × 7
       p n_multiplier graph_type true_g true_b prior_g prior_b
   <dbl>        <dbl> <fct>       <dbl>  <dbl>   <dbl>   <dbl>
 1    25            1 scale-free    0.1      3     0.1       3
 2    25            1 scale-free    0.1      3     0.1      NA
 3    25            1 scale-free    0.1      3     0.5       3
 4    25            1 scale-free    0.1      3     0.5      NA
 5    25            1 scale-free    0.1     NA     0.1       3
 6    25            1 scale-free    0.1     NA     0.1      NA
 7    25            1 scale-free    0.1     NA     0.5       3
 8    25            1 scale-free    0.1     NA     0.5      NA
 9    25            1 scale-free    0.5      3     0.1       3
10    25            1 scale-free    0.5      3     0.1      NA
# ℹ 182 more rows
# ℹ Use `print(n = ...)` to see more rows
> # Dynamically set the NA values based on p
> conditions_grid <- conditions_grid %>%
+ mutate(
+ n = p * n_multiplier,
+ true_b = ifelse(is.na(true_b), p, true_b),
+ prior_b = ifelse(is.na(prior_b), p, prior_b),
+ true_g = ifelse(graph_type == "scale-free", NA, true_g),
+ clusters = ifelse(graph_type == "cluster", pmax(2, floor(p / 10)), NA)
+ ) %>%
+ select(-n_multiplier) # Tidy up
> conditions_grid
# A tibble: 192 × 8
       p graph_type true_g true_b prior_g prior_b     n clusters
   <dbl> <fct>       <dbl>  <dbl>   <dbl>   <dbl> <dbl>    <dbl>
 1    25 scale-free     NA      3     0.1       3    25       NA
 2    25 scale-free     NA      3     0.1      25    25       NA
 3    25 scale-free     NA      3     0.5       3    25       NA
 4    25 scale-free     NA      3     0.5      25    25       NA
 5    25 scale-free     NA     25     0.1       3    25       NA
 6    25 scale-free     NA     25     0.1      25    25       NA
 7    25 scale-free     NA     25     0.5       3    25       NA
 8    25 scale-free     NA     25     0.5      25    25       NA
 9    25 scale-free     NA      3     0.1       3    25       NA
10    25 scale-free     NA      3     0.1      25    25       NA
# ℹ 182 more rows
# ℹ Use `print(n = ...)` to see more rows
> # Define the levels for each factor
+ p_levels     <- c(10, 25, 50, 100)
+ n_mult_levels<- c(1, 2, 5) # Multiplier for p, gives n=p and n=5p
+ type_levels  <- c("scale-free", "random", "cluster")
> # Base grid for all combinations that are NOT type-specific
+ base_grid <- expand.grid(
+   p = p_levels,
+   n_multiplier = n_mult_levels,
+   graph_type = type_levels
+ )
> base_grid
     p n_multiplier graph_type
1   10            1 scale-free
2   25            1 scale-free
3   50            1 scale-free
4  100            1 scale-free
5   10            2 scale-free
6   25            2 scale-free
7   50            2 scale-free
8  100            2 scale-free
9   10            5 scale-free
10  25            5 scale-free
11  50            5 scale-free
12 100            5 scale-free
13  10            1     random
14  25            1     random
15  50            1     random
16 100            1     random
17  10            2     random
18  25            2     random
19  50            2     random
20 100            2     random
21  10            5     random
22  25            5     random
23  50            5     random
24 100            5     random
25  10            1    cluster
26  25            1    cluster
27  50            1    cluster
28 100            1    cluster
29  10            2    cluster
30  25            2    cluster
31  50            2    cluster
32 100            2    cluster
33  10            5    cluster
34  25            5    cluster
35  50            5    cluster
36 100            5    cluster
> 2 / (p[1] - 1)
[1] 0.2222222
> 3, p[1]
Error: unexpected ',' in "3,"
> c(0.8, 0.5, 2/(p_levels - 1))
[1] 0.80000000 0.50000000 0.22222222 0.08333333 0.04081633 0.02020202
> # Define the levels for each independent factor
+ p_levels       <- c(10, 25, 50, 100)
+ n_multiplier_levels <- c(1, 2, 5)
+ graph_type_levels   <- c("scale-free", "random", "cluster")
> # Use descriptive placeholders for the true density levels
+ true_g_levels <- c("dense_80", "dense_50", "sparse_dynamic")
> # Use placeholders for the G-Wishart prior levels (makes the final table clearer)
+ # We will replace the NA with the value of 'p' for each row later
+ prior_b_levels <- c(3, NA)
> conditions_grid <- crossing(
+   p = p_levels,
+   n_multiplier = n_multiplier_levels,
+   graph_type = graph_type_levels,
+   true_g_level = true_g_levels,
+   prior_b = prior_b_levels
+ ) %>%
+   # --- Now, calculate the final values and apply logic ---
+   mutate(
+     # Calculate n based on p and the multiplier
+     n = p * n_multiplier,
+ # Calculate the dynamic value for prior_b
+     prior_b = ifelse(is.na(prior_b), p, prior_b),
+ # Calculate the final numeric value for true_g based on the placeholder
+     true_g = case_when(
+       graph_type == "scale-free"       ~ NA_real_, # Not applicable for scale-free
+       true_g_level == "dense_80"       ~ 0.8,
+       true_g_level == "dense_50"       ~ 0.5,
+       true_g_level == "sparse_dynamic" ~ 2 / (p - 1)
+     ),
+ # Define the number of clusters based on p
+     clusters = case_when(
+         graph_type == "cluster" ~ pmax(2, floor(p / 10)),
+         TRUE                    ~ NA_real_ # Not applicable for other types
+     )
+   ) %>%
+   # --- Clean up the grid ---
+   select(-n_multiplier, -true_g_level) %>% # Remove helper columns
+   distinct() %>% # Removes duplicate rows created for scale-free
+   arrange(p, n, graph_type) # Order the grid logically
Error in crossing(p = p_levels, n_multiplier = n_multiplier_levels, graph_type = graph_type_levels,  : 
  could not find function "crossing"
> conditions_grid
# A tibble: 192 × 8
       p graph_type true_g true_b prior_g prior_b     n clusters
   <dbl> <fct>       <dbl>  <dbl>   <dbl>   <dbl> <dbl>    <dbl>
 1    25 scale-free     NA      3     0.1       3    25       NA
 2    25 scale-free     NA      3     0.1      25    25       NA
 3    25 scale-free     NA      3     0.5       3    25       NA
 4    25 scale-free     NA      3     0.5      25    25       NA
 5    25 scale-free     NA     25     0.1       3    25       NA
 6    25 scale-free     NA     25     0.1      25    25       NA
 7    25 scale-free     NA     25     0.5       3    25       NA
 8    25 scale-free     NA     25     0.5      25    25       NA
 9    25 scale-free     NA      3     0.1       3    25       NA
10    25 scale-free     NA      3     0.1      25    25       NA
# ℹ 182 more rows
# ℹ Use `print(n = ...)` to see more rows
> print(conditions_grid, n = Inf)
# A tibble: 192 × 8
        p graph_type true_g true_b prior_g prior_b     n clusters
    <dbl> <fct>       <dbl>  <dbl>   <dbl>   <dbl> <dbl>    <dbl>
  1    25 scale-free   NA        3     0.1       3    25       NA
  2    25 scale-free   NA        3     0.1      25    25       NA
  3    25 scale-free   NA        3     0.5       3    25       NA
  4    25 scale-free   NA        3     0.5      25    25       NA
  5    25 scale-free   NA       25     0.1       3    25       NA
  6    25 scale-free   NA       25     0.1      25    25       NA
  7    25 scale-free   NA       25     0.5       3    25       NA
  8    25 scale-free   NA       25     0.5      25    25       NA
  9    25 scale-free   NA        3     0.1       3    25       NA
 10    25 scale-free   NA        3     0.1      25    25       NA
 11    25 scale-free   NA        3     0.5       3    25       NA
 12    25 scale-free   NA        3     0.5      25    25       NA
 13    25 scale-free   NA       25     0.1       3    25       NA
 14    25 scale-free   NA       25     0.1      25    25       NA
 15    25 scale-free   NA       25     0.5       3    25       NA
 16    25 scale-free   NA       25     0.5      25    25       NA
 17    25 random        0.1      3     0.1       3    25       NA
 18    25 random        0.1      3     0.1      25    25       NA
 19    25 random        0.1      3     0.5       3    25       NA
 20    25 random        0.1      3     0.5      25    25       NA
 21    25 random        0.1     25     0.1       3    25       NA
 22    25 random        0.1     25     0.1      25    25       NA
 23    25 random        0.1     25     0.5       3    25       NA
 24    25 random        0.1     25     0.5      25    25       NA
 25    25 random        0.5      3     0.1       3    25       NA
 26    25 random        0.5      3     0.1      25    25       NA
 27    25 random        0.5      3     0.5       3    25       NA
 28    25 random        0.5      3     0.5      25    25       NA
 29    25 random        0.5     25     0.1       3    25       NA
 30    25 random        0.5     25     0.1      25    25       NA
 31    25 random        0.5     25     0.5       3    25       NA
 32    25 random        0.5     25     0.5      25    25       NA
 33    25 cluster       0.1      3     0.1       3    25        2
 34    25 cluster       0.1      3     0.1      25    25        2
 35    25 cluster       0.1      3     0.5       3    25        2
 36    25 cluster       0.1      3     0.5      25    25        2
 37    25 cluster       0.1     25     0.1       3    25        2
 38    25 cluster       0.1     25     0.1      25    25        2
 39    25 cluster       0.1     25     0.5       3    25        2
 40    25 cluster       0.1     25     0.5      25    25        2
 41    25 cluster       0.5      3     0.1       3    25        2
 42    25 cluster       0.5      3     0.1      25    25        2
 43    25 cluster       0.5      3     0.5       3    25        2
 44    25 cluster       0.5      3     0.5      25    25        2
 45    25 cluster       0.5     25     0.1       3    25        2
 46    25 cluster       0.5     25     0.1      25    25        2
 47    25 cluster       0.5     25     0.5       3    25        2
 48    25 cluster       0.5     25     0.5      25    25        2
 49    25 scale-free   NA        3     0.1       3   125       NA
 50    25 scale-free   NA        3     0.1      25   125       NA
 51    25 scale-free   NA        3     0.5       3   125       NA
 52    25 scale-free   NA        3     0.5      25   125       NA
 53    25 scale-free   NA       25     0.1       3   125       NA
 54    25 scale-free   NA       25     0.1      25   125       NA
 55    25 scale-free   NA       25     0.5       3   125       NA
 56    25 scale-free   NA       25     0.5      25   125       NA
 57    25 scale-free   NA        3     0.1       3   125       NA
 58    25 scale-free   NA        3     0.1      25   125       NA
 59    25 scale-free   NA        3     0.5       3   125       NA
 60    25 scale-free   NA        3     0.5      25   125       NA
 61    25 scale-free   NA       25     0.1       3   125       NA
 62    25 scale-free   NA       25     0.1      25   125       NA
 63    25 scale-free   NA       25     0.5       3   125       NA
 64    25 scale-free   NA       25     0.5      25   125       NA
 65    25 random        0.1      3     0.1       3   125       NA
 66    25 random        0.1      3     0.1      25   125       NA
 67    25 random        0.1      3     0.5       3   125       NA
 68    25 random        0.1      3     0.5      25   125       NA
 69    25 random        0.1     25     0.1       3   125       NA
 70    25 random        0.1     25     0.1      25   125       NA
 71    25 random        0.1     25     0.5       3   125       NA
 72    25 random        0.1     25     0.5      25   125       NA
 73    25 random        0.5      3     0.1       3   125       NA
 74    25 random        0.5      3     0.1      25   125       NA
 75    25 random        0.5      3     0.5       3   125       NA
 76    25 random        0.5      3     0.5      25   125       NA
 77    25 random        0.5     25     0.1       3   125       NA
 78    25 random        0.5     25     0.1      25   125       NA
 79    25 random        0.5     25     0.5       3   125       NA
 80    25 random        0.5     25     0.5      25   125       NA
 81    25 cluster       0.1      3     0.1       3   125        2
 82    25 cluster       0.1      3     0.1      25   125        2
 83    25 cluster       0.1      3     0.5       3   125        2
 84    25 cluster       0.1      3     0.5      25   125        2
 85    25 cluster       0.1     25     0.1       3   125        2
 86    25 cluster       0.1     25     0.1      25   125        2
 87    25 cluster       0.1     25     0.5       3   125        2
 88    25 cluster       0.1     25     0.5      25   125        2
 89    25 cluster       0.5      3     0.1       3   125        2
 90    25 cluster       0.5      3     0.1      25   125        2
 91    25 cluster       0.5      3     0.5       3   125        2
 92    25 cluster       0.5      3     0.5      25   125        2
 93    25 cluster       0.5     25     0.1       3   125        2
 94    25 cluster       0.5     25     0.1      25   125        2
 95    25 cluster       0.5     25     0.5       3   125        2
 96    25 cluster       0.5     25     0.5      25   125        2
 97   100 scale-free   NA        3     0.1       3   100       NA
 98   100 scale-free   NA        3     0.1     100   100       NA
 99   100 scale-free   NA        3     0.5       3   100       NA
100   100 scale-free   NA        3     0.5     100   100       NA
101   100 scale-free   NA      100     0.1       3   100       NA
102   100 scale-free   NA      100     0.1     100   100       NA
103   100 scale-free   NA      100     0.5       3   100       NA
104   100 scale-free   NA      100     0.5     100   100       NA
105   100 scale-free   NA        3     0.1       3   100       NA
106   100 scale-free   NA        3     0.1     100   100       NA
107   100 scale-free   NA        3     0.5       3   100       NA
108   100 scale-free   NA        3     0.5     100   100       NA
109   100 scale-free   NA      100     0.1       3   100       NA
110   100 scale-free   NA      100     0.1     100   100       NA
111   100 scale-free   NA      100     0.5       3   100       NA
112   100 scale-free   NA      100     0.5     100   100       NA
113   100 random        0.1      3     0.1       3   100       NA
114   100 random        0.1      3     0.1     100   100       NA
115   100 random        0.1      3     0.5       3   100       NA
116   100 random        0.1      3     0.5     100   100       NA
117   100 random        0.1    100     0.1       3   100       NA
118   100 random        0.1    100     0.1     100   100       NA
119   100 random        0.1    100     0.5       3   100       NA
120   100 random        0.1    100     0.5     100   100       NA
121   100 random        0.5      3     0.1       3   100       NA
122   100 random        0.5      3     0.1     100   100       NA
123   100 random        0.5      3     0.5       3   100       NA
124   100 random        0.5      3     0.5     100   100       NA
125   100 random        0.5    100     0.1       3   100       NA
126   100 random        0.5    100     0.1     100   100       NA
127   100 random        0.5    100     0.5       3   100       NA
128   100 random        0.5    100     0.5     100   100       NA
129   100 cluster       0.1      3     0.1       3   100       10
130   100 cluster       0.1      3     0.1     100   100       10
131   100 cluster       0.1      3     0.5       3   100       10
132   100 cluster       0.1      3     0.5     100   100       10
133   100 cluster       0.1    100     0.1       3   100       10
134   100 cluster       0.1    100     0.1     100   100       10
135   100 cluster       0.1    100     0.5       3   100       10
136   100 cluster       0.1    100     0.5     100   100       10
137   100 cluster       0.5      3     0.1       3   100       10
138   100 cluster       0.5      3     0.1     100   100       10
139   100 cluster       0.5      3     0.5       3   100       10
140   100 cluster       0.5      3     0.5     100   100       10
141   100 cluster       0.5    100     0.1       3   100       10
142   100 cluster       0.5    100     0.1     100   100       10
143   100 cluster       0.5    100     0.5       3   100       10
144   100 cluster       0.5    100     0.5     100   100       10
145   100 scale-free   NA        3     0.1       3   500       NA
146   100 scale-free   NA        3     0.1     100   500       NA
147   100 scale-free   NA        3     0.5       3   500       NA
148   100 scale-free   NA        3     0.5     100   500       NA
149   100 scale-free   NA      100     0.1       3   500       NA
150   100 scale-free   NA      100     0.1     100   500       NA
151   100 scale-free   NA      100     0.5       3   500       NA
152   100 scale-free   NA      100     0.5     100   500       NA
153   100 scale-free   NA        3     0.1       3   500       NA
154   100 scale-free   NA        3     0.1     100   500       NA
155   100 scale-free   NA        3     0.5       3   500       NA
156   100 scale-free   NA        3     0.5     100   500       NA
157   100 scale-free   NA      100     0.1       3   500       NA
158   100 scale-free   NA      100     0.1     100   500       NA
159   100 scale-free   NA      100     0.5       3   500       NA
160   100 scale-free   NA      100     0.5     100   500       NA
161   100 random        0.1      3     0.1       3   500       NA
162   100 random        0.1      3     0.1     100   500       NA
163   100 random        0.1      3     0.5       3   500       NA
164   100 random        0.1      3     0.5     100   500       NA
165   100 random        0.1    100     0.1       3   500       NA
166   100 random        0.1    100     0.1     100   500       NA
167   100 random        0.1    100     0.5       3   500       NA
168   100 random        0.1    100     0.5     100   500       NA
169   100 random        0.5      3     0.1       3   500       NA
170   100 random        0.5      3     0.1     100   500       NA
171   100 random        0.5      3     0.5       3   500       NA
172   100 random        0.5      3     0.5     100   500       NA
173   100 random        0.5    100     0.1       3   500       NA
174   100 random        0.5    100     0.1     100   500       NA
175   100 random        0.5    100     0.5       3   500       NA
176   100 random        0.5    100     0.5     100   500       NA
177   100 cluster       0.1      3     0.1       3   500       10
178   100 cluster       0.1      3     0.1     100   500       10
179   100 cluster       0.1      3     0.5       3   500       10
180   100 cluster       0.1      3     0.5     100   500       10
181   100 cluster       0.1    100     0.1       3   500       10
182   100 cluster       0.1    100     0.1     100   500       10
183   100 cluster       0.1    100     0.5       3   500       10
184   100 cluster       0.1    100     0.5     100   500       10
185   100 cluster       0.5      3     0.1       3   500       10
186   100 cluster       0.5      3     0.1     100   500       10
187   100 cluster       0.5      3     0.5       3   500       10
188   100 cluster       0.5      3     0.5     100   500       10
189   100 cluster       0.5    100     0.1       3   500       10
190   100 cluster       0.5    100     0.1     100   500       10
191   100 cluster       0.5    100     0.5       3   500       10
192   100 cluster       0.5    100     0.5     100   500       10
> # For now, let's assume the graph prior is either correctly specified or fixed
+ conditions_grid$prior_g <- conditions_grid$true_g
+ # And for scale-free, let's use a default sparse prior
+ conditions_grid$prior_g[is.na(conditions_grid$prior_g)] <- 2 / (conditions_grid$p[is.na(conditions_grid$prior_g)] - 1)
> # (Optional) Add the true 'b' parameter for the DGP, which we can set equal to the prior for now
+ conditions_grid$true_b <- conditions_grid$prior_b
> conditions_grid
# A tibble: 192 × 8
       p graph_type true_g true_b prior_g prior_b     n clusters
   <dbl> <fct>       <dbl>  <dbl>   <dbl>   <dbl> <dbl>    <dbl>
 1    25 scale-free     NA      3  0.0833       3    25       NA
 2    25 scale-free     NA     25  0.0833      25    25       NA
 3    25 scale-free     NA      3  0.0833       3    25       NA
 4    25 scale-free     NA     25  0.0833      25    25       NA
 5    25 scale-free     NA      3  0.0833       3    25       NA
 6    25 scale-free     NA     25  0.0833      25    25       NA
 7    25 scale-free     NA      3  0.0833       3    25       NA
 8    25 scale-free     NA     25  0.0833      25    25       NA
 9    25 scale-free     NA      3  0.0833       3    25       NA
10    25 scale-free     NA     25  0.0833      25    25       NA
# ℹ 182 more rows
# ℹ Use `print(n = ...)` to see more rows
> print(conditions_grid, n = Inf)
# A tibble: 192 × 8
        p graph_type true_g true_b prior_g prior_b     n clusters
    <dbl> <fct>       <dbl>  <dbl>   <dbl>   <dbl> <dbl>    <dbl>
  1    25 scale-free   NA        3  0.0833       3    25       NA
  2    25 scale-free   NA       25  0.0833      25    25       NA
  3    25 scale-free   NA        3  0.0833       3    25       NA
  4    25 scale-free   NA       25  0.0833      25    25       NA
  5    25 scale-free   NA        3  0.0833       3    25       NA
  6    25 scale-free   NA       25  0.0833      25    25       NA
  7    25 scale-free   NA        3  0.0833       3    25       NA
  8    25 scale-free   NA       25  0.0833      25    25       NA
  9    25 scale-free   NA        3  0.0833       3    25       NA
 10    25 scale-free   NA       25  0.0833      25    25       NA
 11    25 scale-free   NA        3  0.0833       3    25       NA
 12    25 scale-free   NA       25  0.0833      25    25       NA
 13    25 scale-free   NA        3  0.0833       3    25       NA
 14    25 scale-free   NA       25  0.0833      25    25       NA
 15    25 scale-free   NA        3  0.0833       3    25       NA
 16    25 scale-free   NA       25  0.0833      25    25       NA
 17    25 random        0.1      3  0.1          3    25       NA
 18    25 random        0.1     25  0.1         25    25       NA
 19    25 random        0.1      3  0.1          3    25       NA
 20    25 random        0.1     25  0.1         25    25       NA
 21    25 random        0.1      3  0.1          3    25       NA
 22    25 random        0.1     25  0.1         25    25       NA
 23    25 random        0.1      3  0.1          3    25       NA
 24    25 random        0.1     25  0.1         25    25       NA
 25    25 random        0.5      3  0.5          3    25       NA
 26    25 random        0.5     25  0.5         25    25       NA
 27    25 random        0.5      3  0.5          3    25       NA
 28    25 random        0.5     25  0.5         25    25       NA
 29    25 random        0.5      3  0.5          3    25       NA
 30    25 random        0.5     25  0.5         25    25       NA
 31    25 random        0.5      3  0.5          3    25       NA
 32    25 random        0.5     25  0.5         25    25       NA
 33    25 cluster       0.1      3  0.1          3    25        2
 34    25 cluster       0.1     25  0.1         25    25        2
 35    25 cluster       0.1      3  0.1          3    25        2
 36    25 cluster       0.1     25  0.1         25    25        2
 37    25 cluster       0.1      3  0.1          3    25        2
 38    25 cluster       0.1     25  0.1         25    25        2
 39    25 cluster       0.1      3  0.1          3    25        2
 40    25 cluster       0.1     25  0.1         25    25        2
 41    25 cluster       0.5      3  0.5          3    25        2
 42    25 cluster       0.5     25  0.5         25    25        2
 43    25 cluster       0.5      3  0.5          3    25        2
 44    25 cluster       0.5     25  0.5         25    25        2
 45    25 cluster       0.5      3  0.5          3    25        2
 46    25 cluster       0.5     25  0.5         25    25        2
 47    25 cluster       0.5      3  0.5          3    25        2
 48    25 cluster       0.5     25  0.5         25    25        2
 49    25 scale-free   NA        3  0.0833       3   125       NA
 50    25 scale-free   NA       25  0.0833      25   125       NA
 51    25 scale-free   NA        3  0.0833       3   125       NA
 52    25 scale-free   NA       25  0.0833      25   125       NA
 53    25 scale-free   NA        3  0.0833       3   125       NA
 54    25 scale-free   NA       25  0.0833      25   125       NA
 55    25 scale-free   NA        3  0.0833       3   125       NA
 56    25 scale-free   NA       25  0.0833      25   125       NA
 57    25 scale-free   NA        3  0.0833       3   125       NA
 58    25 scale-free   NA       25  0.0833      25   125       NA
 59    25 scale-free   NA        3  0.0833       3   125       NA
 60    25 scale-free   NA       25  0.0833      25   125       NA
 61    25 scale-free   NA        3  0.0833       3   125       NA
 62    25 scale-free   NA       25  0.0833      25   125       NA
 63    25 scale-free   NA        3  0.0833       3   125       NA
 64    25 scale-free   NA       25  0.0833      25   125       NA
 65    25 random        0.1      3  0.1          3   125       NA
 66    25 random        0.1     25  0.1         25   125       NA
 67    25 random        0.1      3  0.1          3   125       NA
 68    25 random        0.1     25  0.1         25   125       NA
 69    25 random        0.1      3  0.1          3   125       NA
 70    25 random        0.1     25  0.1         25   125       NA
 71    25 random        0.1      3  0.1          3   125       NA
 72    25 random        0.1     25  0.1         25   125       NA
 73    25 random        0.5      3  0.5          3   125       NA
 74    25 random        0.5     25  0.5         25   125       NA
 75    25 random        0.5      3  0.5          3   125       NA
 76    25 random        0.5     25  0.5         25   125       NA
 77    25 random        0.5      3  0.5          3   125       NA
 78    25 random        0.5     25  0.5         25   125       NA
 79    25 random        0.5      3  0.5          3   125       NA
 80    25 random        0.5     25  0.5         25   125       NA
 81    25 cluster       0.1      3  0.1          3   125        2
 82    25 cluster       0.1     25  0.1         25   125        2
 83    25 cluster       0.1      3  0.1          3   125        2
 84    25 cluster       0.1     25  0.1         25   125        2
 85    25 cluster       0.1      3  0.1          3   125        2
 86    25 cluster       0.1     25  0.1         25   125        2
 87    25 cluster       0.1      3  0.1          3   125        2
 88    25 cluster       0.1     25  0.1         25   125        2
 89    25 cluster       0.5      3  0.5          3   125        2
 90    25 cluster       0.5     25  0.5         25   125        2
 91    25 cluster       0.5      3  0.5          3   125        2
 92    25 cluster       0.5     25  0.5         25   125        2
 93    25 cluster       0.5      3  0.5          3   125        2
 94    25 cluster       0.5     25  0.5         25   125        2
 95    25 cluster       0.5      3  0.5          3   125        2
 96    25 cluster       0.5     25  0.5         25   125        2
 97   100 scale-free   NA        3  0.0202       3   100       NA
 98   100 scale-free   NA      100  0.0202     100   100       NA
 99   100 scale-free   NA        3  0.0202       3   100       NA
100   100 scale-free   NA      100  0.0202     100   100       NA
101   100 scale-free   NA        3  0.0202       3   100       NA
102   100 scale-free   NA      100  0.0202     100   100       NA
103   100 scale-free   NA        3  0.0202       3   100       NA
104   100 scale-free   NA      100  0.0202     100   100       NA
105   100 scale-free   NA        3  0.0202       3   100       NA
106   100 scale-free   NA      100  0.0202     100   100       NA
107   100 scale-free   NA        3  0.0202       3   100       NA
108   100 scale-free   NA      100  0.0202     100   100       NA
109   100 scale-free   NA        3  0.0202       3   100       NA
110   100 scale-free   NA      100  0.0202     100   100       NA
111   100 scale-free   NA        3  0.0202       3   100       NA
112   100 scale-free   NA      100  0.0202     100   100       NA
113   100 random        0.1      3  0.1          3   100       NA
114   100 random        0.1    100  0.1        100   100       NA
115   100 random        0.1      3  0.1          3   100       NA
116   100 random        0.1    100  0.1        100   100       NA
117   100 random        0.1      3  0.1          3   100       NA
118   100 random        0.1    100  0.1        100   100       NA
119   100 random        0.1      3  0.1          3   100       NA
120   100 random        0.1    100  0.1        100   100       NA
121   100 random        0.5      3  0.5          3   100       NA
122   100 random        0.5    100  0.5        100   100       NA
123   100 random        0.5      3  0.5          3   100       NA
124   100 random        0.5    100  0.5        100   100       NA
125   100 random        0.5      3  0.5          3   100       NA
126   100 random        0.5    100  0.5        100   100       NA
127   100 random        0.5      3  0.5          3   100       NA
128   100 random        0.5    100  0.5        100   100       NA
129   100 cluster       0.1      3  0.1          3   100       10
130   100 cluster       0.1    100  0.1        100   100       10
131   100 cluster       0.1      3  0.1          3   100       10
132   100 cluster       0.1    100  0.1        100   100       10
133   100 cluster       0.1      3  0.1          3   100       10
134   100 cluster       0.1    100  0.1        100   100       10
135   100 cluster       0.1      3  0.1          3   100       10
136   100 cluster       0.1    100  0.1        100   100       10
137   100 cluster       0.5      3  0.5          3   100       10
138   100 cluster       0.5    100  0.5        100   100       10
139   100 cluster       0.5      3  0.5          3   100       10
140   100 cluster       0.5    100  0.5        100   100       10
141   100 cluster       0.5      3  0.5          3   100       10
142   100 cluster       0.5    100  0.5        100   100       10
143   100 cluster       0.5      3  0.5          3   100       10
144   100 cluster       0.5    100  0.5        100   100       10
145   100 scale-free   NA        3  0.0202       3   500       NA
146   100 scale-free   NA      100  0.0202     100   500       NA
147   100 scale-free   NA        3  0.0202       3   500       NA
148   100 scale-free   NA      100  0.0202     100   500       NA
149   100 scale-free   NA        3  0.0202       3   500       NA
150   100 scale-free   NA      100  0.0202     100   500       NA
151   100 scale-free   NA        3  0.0202       3   500       NA
152   100 scale-free   NA      100  0.0202     100   500       NA
153   100 scale-free   NA        3  0.0202       3   500       NA
154   100 scale-free   NA      100  0.0202     100   500       NA
155   100 scale-free   NA        3  0.0202       3   500       NA
156   100 scale-free   NA      100  0.0202     100   500       NA
157   100 scale-free   NA        3  0.0202       3   500       NA
158   100 scale-free   NA      100  0.0202     100   500       NA
159   100 scale-free   NA        3  0.0202       3   500       NA
160   100 scale-free   NA      100  0.0202     100   500       NA
161   100 random        0.1      3  0.1          3   500       NA
162   100 random        0.1    100  0.1        100   500       NA
163   100 random        0.1      3  0.1          3   500       NA
164   100 random        0.1    100  0.1        100   500       NA
165   100 random        0.1      3  0.1          3   500       NA
166   100 random        0.1    100  0.1        100   500       NA
167   100 random        0.1      3  0.1          3   500       NA
168   100 random        0.1    100  0.1        100   500       NA
169   100 random        0.5      3  0.5          3   500       NA
170   100 random        0.5    100  0.5        100   500       NA
171   100 random        0.5      3  0.5          3   500       NA
172   100 random        0.5    100  0.5        100   500       NA
173   100 random        0.5      3  0.5          3   500       NA
174   100 random        0.5    100  0.5        100   500       NA
175   100 random        0.5      3  0.5          3   500       NA
176   100 random        0.5    100  0.5        100   500       NA
177   100 cluster       0.1      3  0.1          3   500       10
178   100 cluster       0.1    100  0.1        100   500       10
179   100 cluster       0.1      3  0.1          3   500       10
180   100 cluster       0.1    100  0.1        100   500       10
181   100 cluster       0.1      3  0.1          3   500       10
182   100 cluster       0.1    100  0.1        100   500       10
183   100 cluster       0.1      3  0.1          3   500       10
184   100 cluster       0.1    100  0.1        100   500       10
185   100 cluster       0.5      3  0.5          3   500       10
186   100 cluster       0.5    100  0.5        100   500       10
187   100 cluster       0.5      3  0.5          3   500       10
188   100 cluster       0.5    100  0.5        100   500       10
189   100 cluster       0.5      3  0.5          3   500       10
190   100 cluster       0.5    100  0.5        100   500       10
191   100 cluster       0.5      3  0.5          3   500       10
192   100 cluster       0.5    100  0.5        100   500       10
> # Define the levels for each independent factor
+ p_levels       <- c(10, 25, 50, 100)
+ n_multiplier_levels <- c(1, 2, 5)
+ graph_type_levels   <- c("scale-free", "random", "cluster")
> # Use descriptive placeholders for the true density levels
+ true_g_levels <- c("dense_80", "dense_50", "sparse_dynamic")
> # Use placeholders for the G-Wishart prior levels (makes the final table clearer)
+ # We will replace the NA with the value of 'p' for each row later
+ prior_b_levels <- c(3, NA)
> conditions_grid <- crossing(
+   p = p_levels,
+   n_multiplier = n_multiplier_levels,
+   graph_type = graph_type_levels,
+   true_g_level = true_g_levels,
+   prior_b = prior_b_levels
+ ) %>%
+   # --- Now, calculate the final values and apply logic ---
+   mutate(
+     # Calculate n based on p and the multiplier
+     n = p * n_multiplier,
+ # Calculate the dynamic value for prior_b
+     prior_b = ifelse(is.na(prior_b), p, prior_b),
+ # Calculate the final numeric value for true_g based on the placeholder
+     true_g = case_when(
+       graph_type == "scale-free"       ~ NA_real_, # Not applicable for scale-free
+       true_g_level == "dense_80"       ~ 0.8,
+       true_g_level == "dense_50"       ~ 0.5,
+       true_g_level == "sparse_dynamic" ~ 2 / (p - 1)
+     ),
+ # Define the number of clusters based on p
+     clusters = case_when(
+         graph_type == "cluster" ~ pmax(2, floor(p / 10)),
+         TRUE                    ~ NA_real_ # Not applicable for other types
+     )
+   ) %>%
+   # --- Clean up the grid ---
+   select(-n_multiplier, -true_g_level) %>% # Remove helper columns
+   distinct() %>% # Removes duplicate rows created for scale-free
+   arrange(p, n, graph_type) # Order the grid logically
Error in crossing(p = p_levels, n_multiplier = n_multiplier_levels, graph_type = graph_type_levels,  : 
  could not find function "crossing"
> # For now, let's assume the graph prior is either correctly specified or fixed
+ conditions_grid$prior_g <- conditions_grid$true_g
+ # And for scale-free, let's use a default sparse prior
+ conditions_grid$prior_g[is.na(conditions_grid$prior_g)] <- 2 / (conditions_grid$p[is.na(conditions_grid$prior_g)] - 1)
> # (Optional) Add the true 'b' parameter for the DGP, which we can set equal to the prior for now
+ conditions_grid$true_b <- conditions_grid$prior_b
> # Let's inspect the first few rows to see the result
+ print(head(conditions_grid, 10))
+ cat("\nTotal number of unique conditions:", nrow(conditions_grid), "\n")
> # A tibble: 10 × 8
       p graph_type true_g true_b prior_g prior_b     n clusters
   <dbl> <fct>       <dbl>  <dbl>   <dbl>   <dbl> <dbl>    <dbl>
 1    25 scale-free     NA      3  0.0833       3    25       NA
 2    25 scale-free     NA     25  0.0833      25    25       NA
 3    25 scale-free     NA      3  0.0833       3    25       NA
 4    25 scale-free     NA     25  0.0833      25    25       NA
 5    25 scale-free     NA      3  0.0833       3    25       NA
 6    25 scale-free     NA     25  0.0833      25    25       NA
 7    25 scale-free     NA      3  0.0833       3    25       NA
 8    25 scale-free     NA     25  0.0833      25    25       NA
 9    25 scale-free     NA      3  0.0833       3    25       NA
10    25 scale-free     NA     25  0.0833      25    25       NA
> 
Total number of unique conditions: 192 
> # Let's inspect the first few rows to see the result
+ print(head(conditions_grid, 10))
+ cat("\nTotal number of unique conditions:", nrow(conditions_grid), "\n")
> # A tibble: 10 × 8
       p graph_type true_g true_b prior_g prior_b     n clusters
   <dbl> <fct>       <dbl>  <dbl>   <dbl>   <dbl> <dbl>    <dbl>
 1    25 scale-free     NA      3  0.0833       3    25       NA
 2    25 scale-free     NA     25  0.0833      25    25       NA
 3    25 scale-free     NA      3  0.0833       3    25       NA
 4    25 scale-free     NA     25  0.0833      25    25       NA
 5    25 scale-free     NA      3  0.0833       3    25       NA
 6    25 scale-free     NA     25  0.0833      25    25       NA
 7    25 scale-free     NA      3  0.0833       3    25       NA
 8    25 scale-free     NA     25  0.0833      25    25       NA
 9    25 scale-free     NA      3  0.0833       3    25       NA
10    25 scale-free     NA     25  0.0833      25    25       NA
> 
Total number of unique conditions: 192 
> crossing(
+   p = p_levels,
+   n_multiplier = n_multiplier_levels,
+   graph_type = graph_type_levels,
+   true_g_level = true_g_levels,
+   prior_b = prior_b_levels
+ )
Error in crossing(p = p_levels, n_multiplier = n_multiplier_levels, graph_type = graph_type_levels,  : 
  could not find function "crossing"
> conditions_grid <- tidyr::crossing(
+   p = p_levels,
+   n_multiplier = n_multiplier_levels,
+   graph_type = graph_type_levels,
+   true_g_level = true_g_levels,
+   prior_b = prior_b_levels
+ ) %>%
+   # --- Now, calculate the final values and apply logic ---
+   mutate(
+     # Calculate n based on p and the multiplier
+     n = p * n_multiplier,
+ # Calculate the dynamic value for prior_b
+     prior_b = ifelse(is.na(prior_b), p, prior_b),
+ # Calculate the final numeric value for true_g based on the placeholder
+     true_g = case_when(
+       graph_type == "scale-free"       ~ NA_real_, # Not applicable for scale-free
+       true_g_level == "dense_80"       ~ 0.8,
+       true_g_level == "dense_50"       ~ 0.5,
+       true_g_level == "sparse_dynamic" ~ 2 / (p - 1)
+     ),
+ # Define the number of clusters based on p
+     clusters = case_when(
+         graph_type == "cluster" ~ pmax(2, floor(p / 10)),
+         TRUE                    ~ NA_real_ # Not applicable for other types
+     )
+   ) %>%
+   # --- Clean up the grid ---
+   select(-n_multiplier, -true_g_level) %>% # Remove helper columns
+   distinct() %>% # Removes duplicate rows created for scale-free
+   arrange(p, n, graph_type) # Order the grid logically
> # For now, let's assume the graph prior is either correctly specified or fixed
+ conditions_grid$prior_g <- conditions_grid$true_g
+ # And for scale-free, let's use a default sparse prior
+ conditions_grid$prior_g[is.na(conditions_grid$prior_g)] <- 2 / (conditions_grid$p[is.na(conditions_grid$prior_g)] - 1)
> # (Optional) Add the true 'b' parameter for the DGP, which we can set equal to the prior for now
+ conditions_grid$true_b <- conditions_grid$prior_b
> # Let's inspect the first few rows to see the result
+ print(head(conditions_grid, 10))
+ cat("\nTotal number of unique conditions:", nrow(conditions_grid), "\n")
> # A tibble: 10 × 8
       p graph_type prior_b     n true_g clusters prior_g true_b
   <dbl> <chr>        <dbl> <dbl>  <dbl>    <dbl>   <dbl>  <dbl>
 1    10 cluster          3    10  0.5          2   0.5        3
 2    10 cluster         10    10  0.5          2   0.5       10
 3    10 cluster          3    10  0.8          2   0.8        3
 4    10 cluster         10    10  0.8          2   0.8       10
 5    10 cluster          3    10  0.222        2   0.222      3
 6    10 cluster         10    10  0.222        2   0.222     10
 7    10 random           3    10  0.5         NA   0.5        3
 8    10 random          10    10  0.5         NA   0.5       10
 9    10 random           3    10  0.8         NA   0.8        3
10    10 random          10    10  0.8         NA   0.8       10
> 
Total number of unique conditions: 168 
> # Let's inspect the first few rows to see the result
+ print(head(conditions_grid, 10))
+ cat("\nTotal number of unique conditions:", nrow(conditions_grid), "\n")
> # A tibble: 10 × 8
       p graph_type prior_b     n true_g clusters prior_g true_b
   <dbl> <chr>        <dbl> <dbl>  <dbl>    <dbl>   <dbl>  <dbl>
 1    10 cluster          3    10  0.5          2   0.5        3
 2    10 cluster         10    10  0.5          2   0.5       10
 3    10 cluster          3    10  0.8          2   0.8        3
 4    10 cluster         10    10  0.8          2   0.8       10
 5    10 cluster          3    10  0.222        2   0.222      3
 6    10 cluster         10    10  0.222        2   0.222     10
 7    10 random           3    10  0.5         NA   0.5        3
 8    10 random          10    10  0.5         NA   0.5       10
 9    10 random           3    10  0.8         NA   0.8        3
10    10 random          10    10  0.8         NA   0.8       10
> 
Total number of unique conditions: 168 
> print(conditions_grid, n = Inf)
# A tibble: 168 × 8
        p graph_type prior_b     n  true_g clusters prior_g true_b
    <dbl> <chr>        <dbl> <dbl>   <dbl>    <dbl>   <dbl>  <dbl>
  1    10 cluster          3    10  0.5           2  0.5         3
  2    10 cluster         10    10  0.5           2  0.5        10
  3    10 cluster          3    10  0.8           2  0.8         3
  4    10 cluster         10    10  0.8           2  0.8        10
  5    10 cluster          3    10  0.222         2  0.222       3
  6    10 cluster         10    10  0.222         2  0.222      10
  7    10 random           3    10  0.5          NA  0.5         3
  8    10 random          10    10  0.5          NA  0.5        10
  9    10 random           3    10  0.8          NA  0.8         3
 10    10 random          10    10  0.8          NA  0.8        10
 11    10 random           3    10  0.222        NA  0.222       3
 12    10 random          10    10  0.222        NA  0.222      10
 13    10 scale-free       3    10 NA            NA  0.222       3
 14    10 scale-free      10    10 NA            NA  0.222      10
 15    10 cluster          3    20  0.5           2  0.5         3
 16    10 cluster         10    20  0.5           2  0.5        10
 17    10 cluster          3    20  0.8           2  0.8         3
 18    10 cluster         10    20  0.8           2  0.8        10
 19    10 cluster          3    20  0.222         2  0.222       3
 20    10 cluster         10    20  0.222         2  0.222      10
 21    10 random           3    20  0.5          NA  0.5         3
 22    10 random          10    20  0.5          NA  0.5        10
 23    10 random           3    20  0.8          NA  0.8         3
 24    10 random          10    20  0.8          NA  0.8        10
 25    10 random           3    20  0.222        NA  0.222       3
 26    10 random          10    20  0.222        NA  0.222      10
 27    10 scale-free       3    20 NA            NA  0.222       3
 28    10 scale-free      10    20 NA            NA  0.222      10
 29    10 cluster          3    50  0.5           2  0.5         3
 30    10 cluster         10    50  0.5           2  0.5        10
 31    10 cluster          3    50  0.8           2  0.8         3
 32    10 cluster         10    50  0.8           2  0.8        10
 33    10 cluster          3    50  0.222         2  0.222       3
 34    10 cluster         10    50  0.222         2  0.222      10
 35    10 random           3    50  0.5          NA  0.5         3
 36    10 random          10    50  0.5          NA  0.5        10
 37    10 random           3    50  0.8          NA  0.8         3
 38    10 random          10    50  0.8          NA  0.8        10
 39    10 random           3    50  0.222        NA  0.222       3
 40    10 random          10    50  0.222        NA  0.222      10
 41    10 scale-free       3    50 NA            NA  0.222       3
 42    10 scale-free      10    50 NA            NA  0.222      10
 43    25 cluster          3    25  0.5           2  0.5         3
 44    25 cluster         25    25  0.5           2  0.5        25
 45    25 cluster          3    25  0.8           2  0.8         3
 46    25 cluster         25    25  0.8           2  0.8        25
 47    25 cluster          3    25  0.0833        2  0.0833      3
 48    25 cluster         25    25  0.0833        2  0.0833     25
 49    25 random           3    25  0.5          NA  0.5         3
 50    25 random          25    25  0.5          NA  0.5        25
 51    25 random           3    25  0.8          NA  0.8         3
 52    25 random          25    25  0.8          NA  0.8        25
 53    25 random           3    25  0.0833       NA  0.0833      3
 54    25 random          25    25  0.0833       NA  0.0833     25
 55    25 scale-free       3    25 NA            NA  0.0833      3
 56    25 scale-free      25    25 NA            NA  0.0833     25
 57    25 cluster          3    50  0.5           2  0.5         3
 58    25 cluster         25    50  0.5           2  0.5        25
 59    25 cluster          3    50  0.8           2  0.8         3
 60    25 cluster         25    50  0.8           2  0.8        25
 61    25 cluster          3    50  0.0833        2  0.0833      3
 62    25 cluster         25    50  0.0833        2  0.0833     25
 63    25 random           3    50  0.5          NA  0.5         3
 64    25 random          25    50  0.5          NA  0.5        25
 65    25 random           3    50  0.8          NA  0.8         3
 66    25 random          25    50  0.8          NA  0.8        25
 67    25 random           3    50  0.0833       NA  0.0833      3
 68    25 random          25    50  0.0833       NA  0.0833     25
 69    25 scale-free       3    50 NA            NA  0.0833      3
 70    25 scale-free      25    50 NA            NA  0.0833     25
 71    25 cluster          3   125  0.5           2  0.5         3
 72    25 cluster         25   125  0.5           2  0.5        25
 73    25 cluster          3   125  0.8           2  0.8         3
 74    25 cluster         25   125  0.8           2  0.8        25
 75    25 cluster          3   125  0.0833        2  0.0833      3
 76    25 cluster         25   125  0.0833        2  0.0833     25
 77    25 random           3   125  0.5          NA  0.5         3
 78    25 random          25   125  0.5          NA  0.5        25
 79    25 random           3   125  0.8          NA  0.8         3
 80    25 random          25   125  0.8          NA  0.8        25
 81    25 random           3   125  0.0833       NA  0.0833      3
 82    25 random          25   125  0.0833       NA  0.0833     25
 83    25 scale-free       3   125 NA            NA  0.0833      3
 84    25 scale-free      25   125 NA            NA  0.0833     25
 85    50 cluster          3    50  0.5           5  0.5         3
 86    50 cluster         50    50  0.5           5  0.5        50
 87    50 cluster          3    50  0.8           5  0.8         3
 88    50 cluster         50    50  0.8           5  0.8        50
 89    50 cluster          3    50  0.0408        5  0.0408      3
 90    50 cluster         50    50  0.0408        5  0.0408     50
 91    50 random           3    50  0.5          NA  0.5         3
 92    50 random          50    50  0.5          NA  0.5        50
 93    50 random           3    50  0.8          NA  0.8         3
 94    50 random          50    50  0.8          NA  0.8        50
 95    50 random           3    50  0.0408       NA  0.0408      3
 96    50 random          50    50  0.0408       NA  0.0408     50
 97    50 scale-free       3    50 NA            NA  0.0408      3
 98    50 scale-free      50    50 NA            NA  0.0408     50
 99    50 cluster          3   100  0.5           5  0.5         3
100    50 cluster         50   100  0.5           5  0.5        50
101    50 cluster          3   100  0.8           5  0.8         3
102    50 cluster         50   100  0.8           5  0.8        50
103    50 cluster          3   100  0.0408        5  0.0408      3
104    50 cluster         50   100  0.0408        5  0.0408     50
105    50 random           3   100  0.5          NA  0.5         3
106    50 random          50   100  0.5          NA  0.5        50
107    50 random           3   100  0.8          NA  0.8         3
108    50 random          50   100  0.8          NA  0.8        50
109    50 random           3   100  0.0408       NA  0.0408      3
110    50 random          50   100  0.0408       NA  0.0408     50
111    50 scale-free       3   100 NA            NA  0.0408      3
112    50 scale-free      50   100 NA            NA  0.0408     50
113    50 cluster          3   250  0.5           5  0.5         3
114    50 cluster         50   250  0.5           5  0.5        50
115    50 cluster          3   250  0.8           5  0.8         3
116    50 cluster         50   250  0.8           5  0.8        50
117    50 cluster          3   250  0.0408        5  0.0408      3
118    50 cluster         50   250  0.0408        5  0.0408     50
119    50 random           3   250  0.5          NA  0.5         3
120    50 random          50   250  0.5          NA  0.5        50
121    50 random           3   250  0.8          NA  0.8         3
122    50 random          50   250  0.8          NA  0.8        50
123    50 random           3   250  0.0408       NA  0.0408      3
124    50 random          50   250  0.0408       NA  0.0408     50
125    50 scale-free       3   250 NA            NA  0.0408      3
126    50 scale-free      50   250 NA            NA  0.0408     50
127   100 cluster          3   100  0.5          10  0.5         3
128   100 cluster        100   100  0.5          10  0.5       100
129   100 cluster          3   100  0.8          10  0.8         3
130   100 cluster        100   100  0.8          10  0.8       100
131   100 cluster          3   100  0.0202       10  0.0202      3
132   100 cluster        100   100  0.0202       10  0.0202    100
133   100 random           3   100  0.5          NA  0.5         3
134   100 random         100   100  0.5          NA  0.5       100
135   100 random           3   100  0.8          NA  0.8         3
136   100 random         100   100  0.8          NA  0.8       100
137   100 random           3   100  0.0202       NA  0.0202      3
138   100 random         100   100  0.0202       NA  0.0202    100
139   100 scale-free       3   100 NA            NA  0.0202      3
140   100 scale-free     100   100 NA            NA  0.0202    100
141   100 cluster          3   200  0.5          10  0.5         3
142   100 cluster        100   200  0.5          10  0.5       100
143   100 cluster          3   200  0.8          10  0.8         3
144   100 cluster        100   200  0.8          10  0.8       100
145   100 cluster          3   200  0.0202       10  0.0202      3
146   100 cluster        100   200  0.0202       10  0.0202    100
147   100 random           3   200  0.5          NA  0.5         3
148   100 random         100   200  0.5          NA  0.5       100
149   100 random           3   200  0.8          NA  0.8         3
150   100 random         100   200  0.8          NA  0.8       100
151   100 random           3   200  0.0202       NA  0.0202      3
152   100 random         100   200  0.0202       NA  0.0202    100
153   100 scale-free       3   200 NA            NA  0.0202      3
154   100 scale-free     100   200 NA            NA  0.0202    100
155   100 cluster          3   500  0.5          10  0.5         3
156   100 cluster        100   500  0.5          10  0.5       100
157   100 cluster          3   500  0.8          10  0.8         3
158   100 cluster        100   500  0.8          10  0.8       100
159   100 cluster          3   500  0.0202       10  0.0202      3
160   100 cluster        100   500  0.0202       10  0.0202    100
161   100 random           3   500  0.5          NA  0.5         3
162   100 random         100   500  0.5          NA  0.5       100
163   100 random           3   500  0.8          NA  0.8         3
164   100 random         100   500  0.8          NA  0.8       100
165   100 random           3   500  0.0202       NA  0.0202      3
166   100 random         100   500  0.0202       NA  0.0202    100
167   100 scale-free       3   500 NA            NA  0.0202      3
168   100 scale-free     100   500 NA            NA  0.0202    100
> . + > p <- c(10, 25, 50, 100)
> dgp_rho <- c(2 / (p[1] - 1), 0.5)     # Sparse vs. Dense
+ dgp_b <- c(3, p[1])              # Diffuse vs. Strict
> # Define the "Prior" parameters for model fitting
+ model_g <- c(2 / (p[1] - 1), 0.5)
+ model_b <- c(3, p[1])
> conditions_grid <- expand.grid(
+   p = rep(p, each=3),
+   n = NA,
+   true_g = NA,
+   prior_g = NA,
+   #true_rho = dgp_rho, # sparsity prior
+   #prior_g = model_g,
+   true_b = dgp_b,
+   prior_b = model_b,
+   graph_type = c("scale-free", "random", "cluster")
+   )
> conditions_grid$n  <- conditions_grid$p * c(1,2,5)
> # Define the true edge probabilities
+ row_indices3 <- rep(which(conditions_grid$graph_type == "random"), each = 3)
+ expanded_grid3 <- conditions_grid[row_indices3, ]
> prob_vector <- unlist(lapply(conditions_grid$p, function(p_val) {
+   # The vector of two probability values to be created for each p
+   c( 0.8, 0.5, 2 / (p_val - 1)) } ) )
> conditions_grid <- rbind(conditions_grid[conditions_grid$graph_type != 'random',], expanded_grid3)
+ conditions_grid$true_g <- ifelse(conditions_grid$graph_type == "random", prob_vector, 0.5)
> # Define the misspecified prior edge probabilities
+ row_indices2 <- rep(which(conditions_grid$graph_type == "random"), each = 3)
+ expanded_grid2 <- conditions_grid[row_indices2, ]
> conditions_grid <- rbind(conditions_grid[conditions_grid$graph_type != 'random',], expanded_grid2)
+ conditions_grid$prior_g <- ifelse(conditions_grid$graph_type == "random", prob_vector, 0.2)
> # Define the number of clusters
+ conditions_grid$clusters <- ifelse(conditions_grid$graph_type == "cluster",
+                                    pmax(2, floor(conditions_grid$p/10)), 1)
> # Fixing the row names
+ rownames(conditions_grid) <- seq(nrow(conditions_grid))
> reps <- 5 # Number of simulation repetitions
+ mcmc_iter <- 5000
+ burnin <- 2000
+ num_chains <- 4 # Number of chains for convergence diagnostics
> results_df <- data.frame()
> conditions_grid
      p   n     true_g    prior_g true_b prior_b graph_type clusters
1    10  10 0.50000000 0.20000000      3       3 scale-free        1
2    10  20 0.50000000 0.20000000      3       3 scale-free        1
3    10  50 0.50000000 0.20000000      3       3 scale-free        1
4    25  25 0.50000000 0.20000000      3       3 scale-free        1
5    25  50 0.50000000 0.20000000      3       3 scale-free        1
6    25 125 0.50000000 0.20000000      3       3 scale-free        1
7    50  50 0.50000000 0.20000000      3       3 scale-free        1
8    50 100 0.50000000 0.20000000      3       3 scale-free        1
9    50 250 0.50000000 0.20000000      3       3 scale-free        1
10  100 100 0.50000000 0.20000000      3       3 scale-free        1
11  100 200 0.50000000 0.20000000      3       3 scale-free        1
12  100 500 0.50000000 0.20000000      3       3 scale-free        1
13   10  10 0.50000000 0.20000000     10       3 scale-free        1
14   10  20 0.50000000 0.20000000     10       3 scale-free        1
15   10  50 0.50000000 0.20000000     10       3 scale-free        1
16   25  25 0.50000000 0.20000000     10       3 scale-free        1
17   25  50 0.50000000 0.20000000     10       3 scale-free        1
18   25 125 0.50000000 0.20000000     10       3 scale-free        1
19   50  50 0.50000000 0.20000000     10       3 scale-free        1
20   50 100 0.50000000 0.20000000     10       3 scale-free        1
21   50 250 0.50000000 0.20000000     10       3 scale-free        1
22  100 100 0.50000000 0.20000000     10       3 scale-free        1
23  100 200 0.50000000 0.20000000     10       3 scale-free        1
24  100 500 0.50000000 0.20000000     10       3 scale-free        1
25   10  10 0.50000000 0.20000000      3      10 scale-free        1
26   10  20 0.50000000 0.20000000      3      10 scale-free        1
27   10  50 0.50000000 0.20000000      3      10 scale-free        1
28   25  25 0.50000000 0.20000000      3      10 scale-free        1
29   25  50 0.50000000 0.20000000      3      10 scale-free        1
30   25 125 0.50000000 0.20000000      3      10 scale-free        1
31   50  50 0.50000000 0.20000000      3      10 scale-free        1
32   50 100 0.50000000 0.20000000      3      10 scale-free        1
33   50 250 0.50000000 0.20000000      3      10 scale-free        1
34  100 100 0.50000000 0.20000000      3      10 scale-free        1
35  100 200 0.50000000 0.20000000      3      10 scale-free        1
36  100 500 0.50000000 0.20000000      3      10 scale-free        1
37   10  10 0.50000000 0.20000000     10      10 scale-free        1
38   10  20 0.50000000 0.20000000     10      10 scale-free        1
39   10  50 0.50000000 0.20000000     10      10 scale-free        1
40   25  25 0.50000000 0.20000000     10      10 scale-free        1
41   25  50 0.50000000 0.20000000     10      10 scale-free        1
42   25 125 0.50000000 0.20000000     10      10 scale-free        1
43   50  50 0.50000000 0.20000000     10      10 scale-free        1
44   50 100 0.50000000 0.20000000     10      10 scale-free        1
45   50 250 0.50000000 0.20000000     10      10 scale-free        1
46  100 100 0.50000000 0.20000000     10      10 scale-free        1
47  100 200 0.50000000 0.20000000     10      10 scale-free        1
48  100 500 0.50000000 0.20000000     10      10 scale-free        1
49   10  10 0.50000000 0.20000000      3       3    cluster        2
50   10  20 0.50000000 0.20000000      3       3    cluster        2
51   10  50 0.50000000 0.20000000      3       3    cluster        2
52   25  25 0.50000000 0.20000000      3       3    cluster        2
53   25  50 0.50000000 0.20000000      3       3    cluster        2
54   25 125 0.50000000 0.20000000      3       3    cluster        2
55   50  50 0.50000000 0.20000000      3       3    cluster        5
56   50 100 0.50000000 0.20000000      3       3    cluster        5
57   50 250 0.50000000 0.20000000      3       3    cluster        5
58  100 100 0.50000000 0.20000000      3       3    cluster       10
59  100 200 0.50000000 0.20000000      3       3    cluster       10
60  100 500 0.50000000 0.20000000      3       3    cluster       10
61   10  10 0.50000000 0.20000000     10       3    cluster        2
62   10  20 0.50000000 0.20000000     10       3    cluster        2
63   10  50 0.50000000 0.20000000     10       3    cluster        2
64   25  25 0.50000000 0.20000000     10       3    cluster        2
65   25  50 0.50000000 0.20000000     10       3    cluster        2
66   25 125 0.50000000 0.20000000     10       3    cluster        2
67   50  50 0.50000000 0.20000000     10       3    cluster        5
68   50 100 0.50000000 0.20000000     10       3    cluster        5
69   50 250 0.50000000 0.20000000     10       3    cluster        5
70  100 100 0.50000000 0.20000000     10       3    cluster       10
71  100 200 0.50000000 0.20000000     10       3    cluster       10
72  100 500 0.50000000 0.20000000     10       3    cluster       10
73   10  10 0.50000000 0.20000000      3      10    cluster        2
74   10  20 0.50000000 0.20000000      3      10    cluster        2
75   10  50 0.50000000 0.20000000      3      10    cluster        2
76   25  25 0.50000000 0.20000000      3      10    cluster        2
77   25  50 0.50000000 0.20000000      3      10    cluster        2
78   25 125 0.50000000 0.20000000      3      10    cluster        2
79   50  50 0.50000000 0.20000000      3      10    cluster        5
80   50 100 0.50000000 0.20000000      3      10    cluster        5
81   50 250 0.50000000 0.20000000      3      10    cluster        5
82  100 100 0.50000000 0.20000000      3      10    cluster       10
83  100 200 0.50000000 0.20000000      3      10    cluster       10
84  100 500 0.50000000 0.20000000      3      10    cluster       10
85   10  10 0.50000000 0.20000000     10      10    cluster        2
86   10  20 0.50000000 0.20000000     10      10    cluster        2
87   10  50 0.50000000 0.20000000     10      10    cluster        2
88   25  25 0.50000000 0.20000000     10      10    cluster        2
89   25  50 0.50000000 0.20000000     10      10    cluster        2
90   25 125 0.50000000 0.20000000     10      10    cluster        2
91   50  50 0.50000000 0.20000000     10      10    cluster        5
92   50 100 0.50000000 0.20000000     10      10    cluster        5
93   50 250 0.50000000 0.20000000     10      10    cluster        5
94  100 100 0.50000000 0.20000000     10      10    cluster       10
95  100 200 0.50000000 0.20000000     10      10    cluster       10
96  100 500 0.50000000 0.20000000     10      10    cluster       10
97   10  10 0.80000000 0.80000000      3       3     random        1
98   10  10 0.80000000 0.50000000      3       3     random        1
99   10  10 0.80000000 0.04081633      3       3     random        1
100  10  10 0.50000000 0.80000000      3       3     random        1
101  10  10 0.50000000 0.50000000      3       3     random        1
102  10  10 0.50000000 0.02020202      3       3     random        1
103  10  10 0.04081633 0.80000000      3       3     random        1
104  10  10 0.04081633 0.50000000      3       3     random        1
105  10  10 0.04081633 0.02020202      3       3     random        1
106  10  20 0.80000000 0.80000000      3       3     random        1
107  10  20 0.80000000 0.50000000      3       3     random        1
108  10  20 0.80000000 0.02020202      3       3     random        1
109  10  20 0.50000000 0.80000000      3       3     random        1
110  10  20 0.50000000 0.50000000      3       3     random        1
111  10  20 0.50000000 0.22222222      3       3     random        1
112  10  20 0.02020202 0.80000000      3       3     random        1
113  10  20 0.02020202 0.50000000      3       3     random        1
114  10  20 0.02020202 0.22222222      3       3     random        1
115  10  50 0.80000000 0.80000000      3       3     random        1
116  10  50 0.80000000 0.50000000      3       3     random        1
117  10  50 0.80000000 0.22222222      3       3     random        1
118  10  50 0.50000000 0.80000000      3       3     random        1
119  10  50 0.50000000 0.50000000      3       3     random        1
120  10  50 0.50000000 0.08333333      3       3     random        1
121  10  50 0.02020202 0.80000000      3       3     random        1
122  10  50 0.02020202 0.50000000      3       3     random        1
123  10  50 0.02020202 0.08333333      3       3     random        1
124  25  25 0.80000000 0.80000000      3       3     random        1
125  25  25 0.80000000 0.50000000      3       3     random        1
126  25  25 0.80000000 0.08333333      3       3     random        1
127  25  25 0.50000000 0.80000000      3       3     random        1
128  25  25 0.50000000 0.50000000      3       3     random        1
129  25  25 0.50000000 0.04081633      3       3     random        1
130  25  25 0.02020202 0.80000000      3       3     random        1
131  25  25 0.02020202 0.50000000      3       3     random        1
132  25  25 0.02020202 0.04081633      3       3     random        1
133  25  50 0.80000000 0.80000000      3       3     random        1
134  25  50 0.80000000 0.50000000      3       3     random        1
135  25  50 0.80000000 0.04081633      3       3     random        1
136  25  50 0.50000000 0.80000000      3       3     random        1
137  25  50 0.50000000 0.50000000      3       3     random        1
138  25  50 0.50000000 0.02020202      3       3     random        1
139  25  50 0.22222222 0.80000000      3       3     random        1
140  25  50 0.22222222 0.50000000      3       3     random        1
141  25  50 0.22222222 0.02020202      3       3     random        1
142  25 125 0.80000000 0.80000000      3       3     random        1
143  25 125 0.80000000 0.50000000      3       3     random        1
144  25 125 0.80000000 0.02020202      3       3     random        1
145  25 125 0.50000000 0.80000000      3       3     random        1
146  25 125 0.50000000 0.50000000      3       3     random        1
147  25 125 0.50000000 0.22222222      3       3     random        1
148  25 125 0.22222222 0.80000000      3       3     random        1
149  25 125 0.22222222 0.50000000      3       3     random        1
150  25 125 0.22222222 0.22222222      3       3     random        1
151  50  50 0.80000000 0.80000000      3       3     random        1
152  50  50 0.80000000 0.50000000      3       3     random        1
153  50  50 0.80000000 0.22222222      3       3     random        1
154  50  50 0.50000000 0.80000000      3       3     random        1
155  50  50 0.50000000 0.50000000      3       3     random        1
156  50  50 0.50000000 0.08333333      3       3     random        1
157  50  50 0.22222222 0.80000000      3       3     random        1
158  50  50 0.22222222 0.50000000      3       3     random        1
159  50  50 0.22222222 0.08333333      3       3     random        1
160  50 100 0.80000000 0.80000000      3       3     random        1
161  50 100 0.80000000 0.50000000      3       3     random        1
162  50 100 0.80000000 0.08333333      3       3     random        1
163  50 100 0.50000000 0.80000000      3       3     random        1
164  50 100 0.50000000 0.50000000      3       3     random        1
165  50 100 0.50000000 0.04081633      3       3     random        1
166  50 100 0.08333333 0.80000000      3       3     random        1
167  50 100 0.08333333 0.50000000      3       3     random        1
168  50 100 0.08333333 0.04081633      3       3     random        1
169  50 250 0.80000000 0.80000000      3       3     random        1
170  50 250 0.80000000 0.50000000      3       3     random        1
171  50 250 0.80000000 0.04081633      3       3     random        1
172  50 250 0.50000000 0.80000000      3       3     random        1
173  50 250 0.50000000 0.50000000      3       3     random        1
174  50 250 0.50000000 0.02020202      3       3     random        1
175  50 250 0.08333333 0.80000000      3       3     random        1
176  50 250 0.08333333 0.50000000      3       3     random        1
177  50 250 0.08333333 0.02020202      3       3     random        1
178 100 100 0.80000000 0.80000000      3       3     random        1
179 100 100 0.80000000 0.50000000      3       3     random        1
180 100 100 0.80000000 0.02020202      3       3     random        1
181 100 100 0.50000000 0.80000000      3       3     random        1
182 100 100 0.50000000 0.50000000      3       3     random        1
183 100 100 0.50000000 0.22222222      3       3     random        1
184 100 100 0.08333333 0.80000000      3       3     random        1
185 100 100 0.08333333 0.50000000      3       3     random        1
186 100 100 0.08333333 0.22222222      3       3     random        1
187 100 200 0.80000000 0.80000000      3       3     random        1
188 100 200 0.80000000 0.50000000      3       3     random        1
189 100 200 0.80000000 0.22222222      3       3     random        1
190 100 200 0.50000000 0.80000000      3       3     random        1
191 100 200 0.50000000 0.50000000      3       3     random        1
192 100 200 0.50000000 0.08333333      3       3     random        1
193 100 200 0.04081633 0.80000000      3       3     random        1
194 100 200 0.04081633 0.50000000      3       3     random        1
195 100 200 0.04081633 0.08333333      3       3     random        1
196 100 500 0.80000000 0.80000000      3       3     random        1
197 100 500 0.80000000 0.50000000      3       3     random        1
198 100 500 0.80000000 0.08333333      3       3     random        1
199 100 500 0.50000000 0.80000000      3       3     random        1
200 100 500 0.50000000 0.50000000      3       3     random        1
201 100 500 0.50000000 0.04081633      3       3     random        1
202 100 500 0.04081633 0.80000000      3       3     random        1
203 100 500 0.04081633 0.50000000      3       3     random        1
204 100 500 0.04081633 0.04081633      3       3     random        1
205  10  10 0.80000000 0.80000000     10       3     random        1
206  10  10 0.80000000 0.50000000     10       3     random        1
207  10  10 0.80000000 0.04081633     10       3     random        1
208  10  10 0.50000000 0.80000000     10       3     random        1
209  10  10 0.50000000 0.50000000     10       3     random        1
210  10  10 0.50000000 0.02020202     10       3     random        1
211  10  10 0.04081633 0.80000000     10       3     random        1
212  10  10 0.04081633 0.50000000     10       3     random        1
213  10  10 0.04081633 0.02020202     10       3     random        1
214  10  20 0.80000000 0.80000000     10       3     random        1
215  10  20 0.80000000 0.50000000     10       3     random        1
216  10  20 0.80000000 0.02020202     10       3     random        1
217  10  20 0.50000000 0.80000000     10       3     random        1
218  10  20 0.50000000 0.50000000     10       3     random        1
219  10  20 0.50000000 0.22222222     10       3     random        1
220  10  20 0.02020202 0.80000000     10       3     random        1
221  10  20 0.02020202 0.50000000     10       3     random        1
222  10  20 0.02020202 0.22222222     10       3     random        1
223  10  50 0.80000000 0.80000000     10       3     random        1
224  10  50 0.80000000 0.50000000     10       3     random        1
225  10  50 0.80000000 0.22222222     10       3     random        1
226  10  50 0.50000000 0.80000000     10       3     random        1
227  10  50 0.50000000 0.50000000     10       3     random        1
228  10  50 0.50000000 0.08333333     10       3     random        1
229  10  50 0.02020202 0.80000000     10       3     random        1
230  10  50 0.02020202 0.50000000     10       3     random        1
231  10  50 0.02020202 0.08333333     10       3     random        1
232  25  25 0.80000000 0.80000000     10       3     random        1
233  25  25 0.80000000 0.50000000     10       3     random        1
234  25  25 0.80000000 0.08333333     10       3     random        1
235  25  25 0.50000000 0.80000000     10       3     random        1
236  25  25 0.50000000 0.50000000     10       3     random        1
237  25  25 0.50000000 0.04081633     10       3     random        1
238  25  25 0.02020202 0.80000000     10       3     random        1
239  25  25 0.02020202 0.50000000     10       3     random        1
240  25  25 0.02020202 0.04081633     10       3     random        1
241  25  50 0.80000000 0.80000000     10       3     random        1
242  25  50 0.80000000 0.50000000     10       3     random        1
243  25  50 0.80000000 0.04081633     10       3     random        1
244  25  50 0.50000000 0.80000000     10       3     random        1
245  25  50 0.50000000 0.50000000     10       3     random        1
246  25  50 0.50000000 0.02020202     10       3     random        1
247  25  50 0.22222222 0.80000000     10       3     random        1
248  25  50 0.22222222 0.50000000     10       3     random        1
249  25  50 0.22222222 0.02020202     10       3     random        1
250  25 125 0.80000000 0.80000000     10       3     random        1
251  25 125 0.80000000 0.50000000     10       3     random        1
252  25 125 0.80000000 0.02020202     10       3     random        1
253  25 125 0.50000000 0.80000000     10       3     random        1
254  25 125 0.50000000 0.50000000     10       3     random        1
255  25 125 0.50000000 0.22222222     10       3     random        1
256  25 125 0.22222222 0.80000000     10       3     random        1
257  25 125 0.22222222 0.50000000     10       3     random        1
258  25 125 0.22222222 0.22222222     10       3     random        1
259  50  50 0.80000000 0.80000000     10       3     random        1
260  50  50 0.80000000 0.50000000     10       3     random        1
261  50  50 0.80000000 0.22222222     10       3     random        1
262  50  50 0.50000000 0.80000000     10       3     random        1
263  50  50 0.50000000 0.50000000     10       3     random        1
264  50  50 0.50000000 0.08333333     10       3     random        1
265  50  50 0.22222222 0.80000000     10       3     random        1
266  50  50 0.22222222 0.50000000     10       3     random        1
267  50  50 0.22222222 0.08333333     10       3     random        1
268  50 100 0.80000000 0.80000000     10       3     random        1
269  50 100 0.80000000 0.50000000     10       3     random        1
270  50 100 0.80000000 0.08333333     10       3     random        1
271  50 100 0.50000000 0.80000000     10       3     random        1
272  50 100 0.50000000 0.50000000     10       3     random        1
273  50 100 0.50000000 0.04081633     10       3     random        1
274  50 100 0.08333333 0.80000000     10       3     random        1
275  50 100 0.08333333 0.50000000     10       3     random        1
276  50 100 0.08333333 0.04081633     10       3     random        1
277  50 250 0.80000000 0.80000000     10       3     random        1
278  50 250 0.80000000 0.50000000     10       3     random        1
279  50 250 0.80000000 0.04081633     10       3     random        1
280  50 250 0.50000000 0.80000000     10       3     random        1
281  50 250 0.50000000 0.50000000     10       3     random        1
282  50 250 0.50000000 0.02020202     10       3     random        1
283  50 250 0.08333333 0.80000000     10       3     random        1
284  50 250 0.08333333 0.50000000     10       3     random        1
285  50 250 0.08333333 0.02020202     10       3     random        1
286 100 100 0.80000000 0.80000000     10       3     random        1
287 100 100 0.80000000 0.50000000     10       3     random        1
288 100 100 0.80000000 0.02020202     10       3     random        1
289 100 100 0.50000000 0.80000000     10       3     random        1
290 100 100 0.50000000 0.50000000     10       3     random        1
291 100 100 0.50000000 0.22222222     10       3     random        1
292 100 100 0.08333333 0.80000000     10       3     random        1
293 100 100 0.08333333 0.50000000     10       3     random        1
294 100 100 0.08333333 0.22222222     10       3     random        1
295 100 200 0.80000000 0.80000000     10       3     random        1
296 100 200 0.80000000 0.50000000     10       3     random        1
297 100 200 0.80000000 0.22222222     10       3     random        1
298 100 200 0.50000000 0.80000000     10       3     random        1
299 100 200 0.50000000 0.50000000     10       3     random        1
300 100 200 0.50000000 0.08333333     10       3     random        1
301 100 200 0.04081633 0.80000000     10       3     random        1
302 100 200 0.04081633 0.50000000     10       3     random        1
303 100 200 0.04081633 0.08333333     10       3     random        1
304 100 500 0.80000000 0.80000000     10       3     random        1
305 100 500 0.80000000 0.50000000     10       3     random        1
306 100 500 0.80000000 0.08333333     10       3     random        1
307 100 500 0.50000000 0.80000000     10       3     random        1
308 100 500 0.50000000 0.50000000     10       3     random        1
309 100 500 0.50000000 0.04081633     10       3     random        1
310 100 500 0.04081633 0.80000000     10       3     random        1
311 100 500 0.04081633 0.50000000     10       3     random        1
312 100 500 0.04081633 0.04081633     10       3     random        1
313  10  10 0.80000000 0.80000000      3      10     random        1
314  10  10 0.80000000 0.50000000      3      10     random        1
315  10  10 0.80000000 0.04081633      3      10     random        1
316  10  10 0.50000000 0.80000000      3      10     random        1
317  10  10 0.50000000 0.50000000      3      10     random        1
318  10  10 0.50000000 0.02020202      3      10     random        1
319  10  10 0.04081633 0.80000000      3      10     random        1
320  10  10 0.04081633 0.50000000      3      10     random        1
321  10  10 0.04081633 0.02020202      3      10     random        1
322  10  20 0.80000000 0.80000000      3      10     random        1
323  10  20 0.80000000 0.50000000      3      10     random        1
324  10  20 0.80000000 0.02020202      3      10     random        1
325  10  20 0.50000000 0.80000000      3      10     random        1
326  10  20 0.50000000 0.50000000      3      10     random        1
327  10  20 0.50000000 0.22222222      3      10     random        1
328  10  20 0.02020202 0.80000000      3      10     random        1
329  10  20 0.02020202 0.50000000      3      10     random        1
330  10  20 0.02020202 0.22222222      3      10     random        1
331  10  50 0.80000000 0.80000000      3      10     random        1
332  10  50 0.80000000 0.50000000      3      10     random        1
333  10  50 0.80000000 0.22222222      3      10     random        1
334  10  50 0.50000000 0.80000000      3      10     random        1
335  10  50 0.50000000 0.50000000      3      10     random        1
336  10  50 0.50000000 0.08333333      3      10     random        1
337  10  50 0.02020202 0.80000000      3      10     random        1
338  10  50 0.02020202 0.50000000      3      10     random        1
339  10  50 0.02020202 0.08333333      3      10     random        1
340  25  25 0.80000000 0.80000000      3      10     random        1
341  25  25 0.80000000 0.50000000      3      10     random        1
342  25  25 0.80000000 0.08333333      3      10     random        1
343  25  25 0.50000000 0.80000000      3      10     random        1
344  25  25 0.50000000 0.50000000      3      10     random        1
345  25  25 0.50000000 0.04081633      3      10     random        1
346  25  25 0.02020202 0.80000000      3      10     random        1
347  25  25 0.02020202 0.50000000      3      10     random        1
348  25  25 0.02020202 0.04081633      3      10     random        1
349  25  50 0.80000000 0.80000000      3      10     random        1
350  25  50 0.80000000 0.50000000      3      10     random        1
351  25  50 0.80000000 0.04081633      3      10     random        1
352  25  50 0.50000000 0.80000000      3      10     random        1
353  25  50 0.50000000 0.50000000      3      10     random        1
354  25  50 0.50000000 0.02020202      3      10     random        1
355  25  50 0.22222222 0.80000000      3      10     random        1
356  25  50 0.22222222 0.50000000      3      10     random        1
357  25  50 0.22222222 0.02020202      3      10     random        1
358  25 125 0.80000000 0.80000000      3      10     random        1
359  25 125 0.80000000 0.50000000      3      10     random        1
360  25 125 0.80000000 0.02020202      3      10     random        1
361  25 125 0.50000000 0.80000000      3      10     random        1
362  25 125 0.50000000 0.50000000      3      10     random        1
363  25 125 0.50000000 0.22222222      3      10     random        1
364  25 125 0.22222222 0.80000000      3      10     random        1
365  25 125 0.22222222 0.50000000      3      10     random        1
366  25 125 0.22222222 0.22222222      3      10     random        1
367  50  50 0.80000000 0.80000000      3      10     random        1
368  50  50 0.80000000 0.50000000      3      10     random        1
369  50  50 0.80000000 0.22222222      3      10     random        1
370  50  50 0.50000000 0.80000000      3      10     random        1
371  50  50 0.50000000 0.50000000      3      10     random        1
372  50  50 0.50000000 0.08333333      3      10     random        1
373  50  50 0.22222222 0.80000000      3      10     random        1
374  50  50 0.22222222 0.50000000      3      10     random        1
375  50  50 0.22222222 0.08333333      3      10     random        1
376  50 100 0.80000000 0.80000000      3      10     random        1
377  50 100 0.80000000 0.50000000      3      10     random        1
378  50 100 0.80000000 0.08333333      3      10     random        1
379  50 100 0.50000000 0.80000000      3      10     random        1
380  50 100 0.50000000 0.50000000      3      10     random        1
381  50 100 0.50000000 0.04081633      3      10     random        1
382  50 100 0.08333333 0.80000000      3      10     random        1
383  50 100 0.08333333 0.50000000      3      10     random        1
384  50 100 0.08333333 0.04081633      3      10     random        1
385  50 250 0.80000000 0.80000000      3      10     random        1
386  50 250 0.80000000 0.50000000      3      10     random        1
387  50 250 0.80000000 0.04081633      3      10     random        1
388  50 250 0.50000000 0.80000000      3      10     random        1
389  50 250 0.50000000 0.50000000      3      10     random        1
390  50 250 0.50000000 0.02020202      3      10     random        1
391  50 250 0.08333333 0.80000000      3      10     random        1
392  50 250 0.08333333 0.50000000      3      10     random        1
393  50 250 0.08333333 0.02020202      3      10     random        1
394 100 100 0.80000000 0.80000000      3      10     random        1
395 100 100 0.80000000 0.50000000      3      10     random        1
396 100 100 0.80000000 0.02020202      3      10     random        1
397 100 100 0.50000000 0.80000000      3      10     random        1
398 100 100 0.50000000 0.50000000      3      10     random        1
399 100 100 0.50000000 0.22222222      3      10     random        1
400 100 100 0.08333333 0.80000000      3      10     random        1
401 100 100 0.08333333 0.50000000      3      10     random        1
402 100 100 0.08333333 0.22222222      3      10     random        1
403 100 200 0.80000000 0.80000000      3      10     random        1
404 100 200 0.80000000 0.50000000      3      10     random        1
405 100 200 0.80000000 0.22222222      3      10     random        1
406 100 200 0.50000000 0.80000000      3      10     random        1
407 100 200 0.50000000 0.50000000      3      10     random        1
408 100 200 0.50000000 0.08333333      3      10     random        1
409 100 200 0.04081633 0.80000000      3      10     random        1
410 100 200 0.04081633 0.50000000      3      10     random        1
411 100 200 0.04081633 0.08333333      3      10     random        1
412 100 500 0.80000000 0.80000000      3      10     random        1
413 100 500 0.80000000 0.50000000      3      10     random        1
414 100 500 0.80000000 0.08333333      3      10     random        1
415 100 500 0.50000000 0.80000000      3      10     random        1
416 100 500 0.50000000 0.50000000      3      10     random        1
417 100 500 0.50000000 0.04081633      3      10     random        1
418 100 500 0.04081633 0.80000000      3      10     random        1
419 100 500 0.04081633 0.50000000      3      10     random        1
420 100 500 0.04081633 0.04081633      3      10     random        1
421  10  10 0.80000000 0.80000000     10      10     random        1
422  10  10 0.80000000 0.50000000     10      10     random        1
423  10  10 0.80000000 0.04081633     10      10     random        1
424  10  10 0.50000000 0.80000000     10      10     random        1
425  10  10 0.50000000 0.50000000     10      10     random        1
426  10  10 0.50000000 0.02020202     10      10     random        1
427  10  10 0.04081633 0.80000000     10      10     random        1
428  10  10 0.04081633 0.50000000     10      10     random        1
429  10  10 0.04081633 0.02020202     10      10     random        1
430  10  20 0.80000000 0.80000000     10      10     random        1
431  10  20 0.80000000 0.50000000     10      10     random        1
432  10  20 0.80000000 0.02020202     10      10     random        1
433  10  20 0.50000000 0.80000000     10      10     random        1
434  10  20 0.50000000 0.50000000     10      10     random        1
435  10  20 0.50000000 0.22222222     10      10     random        1
436  10  20 0.02020202 0.80000000     10      10     random        1
437  10  20 0.02020202 0.50000000     10      10     random        1
438  10  20 0.02020202 0.22222222     10      10     random        1
439  10  50 0.80000000 0.80000000     10      10     random        1
440  10  50 0.80000000 0.50000000     10      10     random        1
441  10  50 0.80000000 0.22222222     10      10     random        1
442  10  50 0.50000000 0.80000000     10      10     random        1
443  10  50 0.50000000 0.50000000     10      10     random        1
444  10  50 0.50000000 0.08333333     10      10     random        1
445  10  50 0.02020202 0.80000000     10      10     random        1
446  10  50 0.02020202 0.50000000     10      10     random        1
447  10  50 0.02020202 0.08333333     10      10     random        1
448  25  25 0.80000000 0.80000000     10      10     random        1
449  25  25 0.80000000 0.50000000     10      10     random        1
450  25  25 0.80000000 0.08333333     10      10     random        1
451  25  25 0.50000000 0.80000000     10      10     random        1
452  25  25 0.50000000 0.50000000     10      10     random        1
453  25  25 0.50000000 0.04081633     10      10     random        1
454  25  25 0.02020202 0.80000000     10      10     random        1
455  25  25 0.02020202 0.50000000     10      10     random        1
456  25  25 0.02020202 0.04081633     10      10     random        1
457  25  50 0.80000000 0.80000000     10      10     random        1
458  25  50 0.80000000 0.50000000     10      10     random        1
459  25  50 0.80000000 0.04081633     10      10     random        1
460  25  50 0.50000000 0.80000000     10      10     random        1
461  25  50 0.50000000 0.50000000     10      10     random        1
462  25  50 0.50000000 0.02020202     10      10     random        1
463  25  50 0.22222222 0.80000000     10      10     random        1
464  25  50 0.22222222 0.50000000     10      10     random        1
465  25  50 0.22222222 0.02020202     10      10     random        1
466  25 125 0.80000000 0.80000000     10      10     random        1
467  25 125 0.80000000 0.50000000     10      10     random        1
468  25 125 0.80000000 0.02020202     10      10     random        1
469  25 125 0.50000000 0.80000000     10      10     random        1
470  25 125 0.50000000 0.50000000     10      10     random        1
471  25 125 0.50000000 0.22222222     10      10     random        1
472  25 125 0.22222222 0.80000000     10      10     random        1
473  25 125 0.22222222 0.50000000     10      10     random        1
474  25 125 0.22222222 0.22222222     10      10     random        1
475  50  50 0.80000000 0.80000000     10      10     random        1
476  50  50 0.80000000 0.50000000     10      10     random        1
477  50  50 0.80000000 0.22222222     10      10     random        1
478  50  50 0.50000000 0.80000000     10      10     random        1
479  50  50 0.50000000 0.50000000     10      10     random        1
480  50  50 0.50000000 0.08333333     10      10     random        1
481  50  50 0.22222222 0.80000000     10      10     random        1
482  50  50 0.22222222 0.50000000     10      10     random        1
483  50  50 0.22222222 0.08333333     10      10     random        1
484  50 100 0.80000000 0.80000000     10      10     random        1
485  50 100 0.80000000 0.50000000     10      10     random        1
486  50 100 0.80000000 0.08333333     10      10     random        1
487  50 100 0.50000000 0.80000000     10      10     random        1
488  50 100 0.50000000 0.50000000     10      10     random        1
489  50 100 0.50000000 0.04081633     10      10     random        1
490  50 100 0.08333333 0.80000000     10      10     random        1
491  50 100 0.08333333 0.50000000     10      10     random        1
492  50 100 0.08333333 0.04081633     10      10     random        1
493  50 250 0.80000000 0.80000000     10      10     random        1
494  50 250 0.80000000 0.50000000     10      10     random        1
495  50 250 0.80000000 0.04081633     10      10     random        1
496  50 250 0.50000000 0.80000000     10      10     random        1
497  50 250 0.50000000 0.50000000     10      10     random        1
498  50 250 0.50000000 0.02020202     10      10     random        1
499  50 250 0.08333333 0.80000000     10      10     random        1
500  50 250 0.08333333 0.50000000     10      10     random        1
501  50 250 0.08333333 0.02020202     10      10     random        1
502 100 100 0.80000000 0.80000000     10      10     random        1
503 100 100 0.80000000 0.50000000     10      10     random        1
504 100 100 0.80000000 0.02020202     10      10     random        1
505 100 100 0.50000000 0.80000000     10      10     random        1
506 100 100 0.50000000 0.50000000     10      10     random        1
507 100 100 0.50000000 0.22222222     10      10     random        1
508 100 100 0.08333333 0.80000000     10      10     random        1
509 100 100 0.08333333 0.50000000     10      10     random        1
510 100 100 0.08333333 0.22222222     10      10     random        1
511 100 200 0.80000000 0.80000000     10      10     random        1
512 100 200 0.80000000 0.50000000     10      10     random        1
513 100 200 0.80000000 0.22222222     10      10     random        1
514 100 200 0.50000000 0.80000000     10      10     random        1
515 100 200 0.50000000 0.50000000     10      10     random        1
516 100 200 0.50000000 0.08333333     10      10     random        1
517 100 200 0.04081633 0.80000000     10      10     random        1
518 100 200 0.04081633 0.50000000     10      10     random        1
519 100 200 0.04081633 0.08333333     10      10     random        1
520 100 500 0.80000000 0.80000000     10      10     random        1
521 100 500 0.80000000 0.50000000     10      10     random        1
522 100 500 0.80000000 0.08333333     10      10     random        1
523 100 500 0.50000000 0.80000000     10      10     random        1
524 100 500 0.50000000 0.50000000     10      10     random        1
525 100 500 0.50000000 0.04081633     10      10     random        1
526 100 500 0.04081633 0.80000000     10      10     random        1
527 100 500 0.04081633 0.50000000     10      10     random        1
528 100 500 0.04081633 0.04081633     10      10     random        1
> get_strength <- function(graph_matrix, precision_matrix) {
+   # Convert precision matrix to partial correlation matrix
+   p_cors <- -cov2cor(precision_matrix)
+   diag(p_cors) <- 0
+ 
+   # Apply the graph structure (set non-edges to zero)
+   weighted_adj_matrix <- p_cors * graph_matrix
+ 
+   # Calculate strength for each node
+   node_strengths <- colSums(abs(weighted_adj_matrix))
+ 
+   return(node_strengths)
+ }
+ 
+ # --- 1. SIMULATION SETUP ---
+ 
+ p <- c(10, 25, 50, 100)
+ 
+ dgp_rho <- c(2 / (p[1] - 1), 0.5)     # Sparse vs. Dense
+ dgp_b <- c(3, p[1])              # Diffuse vs. Strict
+ 
+ # Define the "Prior" parameters for model fitting
+ model_g <- c(2 / (p[1] - 1), 0.5)
+ model_b <- c(3, p[1])
+ 
+ conditions_grid <- expand.grid(
+   p = rep(p, each=3),
+   n = NA,
+   true_g = NA,
+   prior_g = NA,
+   #true_rho = dgp_rho, # sparsity prior
+   #prior_g = model_g,
+   true_b = dgp_b,
+   prior_b = model_b,
+   graph_type = c("scale-free", "random", "cluster")
+   )
+ 
+ conditions_grid$n  <- conditions_grid$p * c(1,2,5)
+ 
+ # Define the true edge probabilities
+ row_indices3 <- rep(which(conditions_grid$graph_type == "random"), each = 3)
+ expanded_grid3 <- conditions_grid[row_indices3, ]
+ 
+ prob_vector <- unlist(lapply(conditions_grid$p, function(p_val) {
+   # The vector of two probability values to be created for each p
+   c( 0.8, 0.5, 2 / (p_val - 1)) } ) )
+ 
+ conditions_grid <- rbind(conditions_grid[conditions_grid$graph_type != 'random',], expanded_grid3)
+ conditions_grid$true_g <- ifelse(conditions_grid$graph_type == "random", prob_vector, 0.2)
+ 
+ # Define the misspecified prior edge probabilities
+ row_indices2 <- rep(which(conditions_grid$graph_type == "random"), each = 3)
+ expanded_grid2 <- conditions_grid[row_indices2, ]
+ 
+ conditions_grid <- rbind(conditions_grid[conditions_grid$graph_type != 'random',], expanded_grid2)
+ conditions_grid$prior_g <- ifelse(conditions_grid$graph_type == "random", prob_vector, 0.2)
+ 
+ # Define the number of clusters
+ conditions_grid$clusters <- ifelse(conditions_grid$graph_type == "cluster",
+                                    pmax(2, floor(conditions_grid$p/10)), 1)
+ 
+ # Fixing the row names
+ rownames(conditions_grid) <- seq(nrow(conditions_grid))
+ 
+ reps <- 5 # Number of simulation repetitions
+ mcmc_iter <- 5000
+ burnin <- 2000
+ num_chains <- 4 # Number of chains for convergence diagnostics
> conditions_grid
      p   n     true_g    prior_g true_b prior_b graph_type clusters
1    10  10 0.20000000 0.20000000      3       3 scale-free        1
2    10  20 0.20000000 0.20000000      3       3 scale-free        1
3    10  50 0.20000000 0.20000000      3       3 scale-free        1
4    25  25 0.20000000 0.20000000      3       3 scale-free        1
5    25  50 0.20000000 0.20000000      3       3 scale-free        1
6    25 125 0.20000000 0.20000000      3       3 scale-free        1
7    50  50 0.20000000 0.20000000      3       3 scale-free        1
8    50 100 0.20000000 0.20000000      3       3 scale-free        1
9    50 250 0.20000000 0.20000000      3       3 scale-free        1
10  100 100 0.20000000 0.20000000      3       3 scale-free        1
11  100 200 0.20000000 0.20000000      3       3 scale-free        1
12  100 500 0.20000000 0.20000000      3       3 scale-free        1
13   10  10 0.20000000 0.20000000     10       3 scale-free        1
14   10  20 0.20000000 0.20000000     10       3 scale-free        1
15   10  50 0.20000000 0.20000000     10       3 scale-free        1
16   25  25 0.20000000 0.20000000     10       3 scale-free        1
17   25  50 0.20000000 0.20000000     10       3 scale-free        1
18   25 125 0.20000000 0.20000000     10       3 scale-free        1
19   50  50 0.20000000 0.20000000     10       3 scale-free        1
20   50 100 0.20000000 0.20000000     10       3 scale-free        1
21   50 250 0.20000000 0.20000000     10       3 scale-free        1
22  100 100 0.20000000 0.20000000     10       3 scale-free        1
23  100 200 0.20000000 0.20000000     10       3 scale-free        1
24  100 500 0.20000000 0.20000000     10       3 scale-free        1
25   10  10 0.20000000 0.20000000      3      10 scale-free        1
26   10  20 0.20000000 0.20000000      3      10 scale-free        1
27   10  50 0.20000000 0.20000000      3      10 scale-free        1
28   25  25 0.20000000 0.20000000      3      10 scale-free        1
29   25  50 0.20000000 0.20000000      3      10 scale-free        1
30   25 125 0.20000000 0.20000000      3      10 scale-free        1
31   50  50 0.20000000 0.20000000      3      10 scale-free        1
32   50 100 0.20000000 0.20000000      3      10 scale-free        1
33   50 250 0.20000000 0.20000000      3      10 scale-free        1
34  100 100 0.20000000 0.20000000      3      10 scale-free        1
35  100 200 0.20000000 0.20000000      3      10 scale-free        1
36  100 500 0.20000000 0.20000000      3      10 scale-free        1
37   10  10 0.20000000 0.20000000     10      10 scale-free        1
38   10  20 0.20000000 0.20000000     10      10 scale-free        1
39   10  50 0.20000000 0.20000000     10      10 scale-free        1
40   25  25 0.20000000 0.20000000     10      10 scale-free        1
41   25  50 0.20000000 0.20000000     10      10 scale-free        1
42   25 125 0.20000000 0.20000000     10      10 scale-free        1
43   50  50 0.20000000 0.20000000     10      10 scale-free        1
44   50 100 0.20000000 0.20000000     10      10 scale-free        1
45   50 250 0.20000000 0.20000000     10      10 scale-free        1
46  100 100 0.20000000 0.20000000     10      10 scale-free        1
47  100 200 0.20000000 0.20000000     10      10 scale-free        1
48  100 500 0.20000000 0.20000000     10      10 scale-free        1
49   10  10 0.20000000 0.20000000      3       3    cluster        2
50   10  20 0.20000000 0.20000000      3       3    cluster        2
51   10  50 0.20000000 0.20000000      3       3    cluster        2
52   25  25 0.20000000 0.20000000      3       3    cluster        2
53   25  50 0.20000000 0.20000000      3       3    cluster        2
54   25 125 0.20000000 0.20000000      3       3    cluster        2
55   50  50 0.20000000 0.20000000      3       3    cluster        5
56   50 100 0.20000000 0.20000000      3       3    cluster        5
57   50 250 0.20000000 0.20000000      3       3    cluster        5
58  100 100 0.20000000 0.20000000      3       3    cluster       10
59  100 200 0.20000000 0.20000000      3       3    cluster       10
60  100 500 0.20000000 0.20000000      3       3    cluster       10
61   10  10 0.20000000 0.20000000     10       3    cluster        2
62   10  20 0.20000000 0.20000000     10       3    cluster        2
63   10  50 0.20000000 0.20000000     10       3    cluster        2
64   25  25 0.20000000 0.20000000     10       3    cluster        2
65   25  50 0.20000000 0.20000000     10       3    cluster        2
66   25 125 0.20000000 0.20000000     10       3    cluster        2
67   50  50 0.20000000 0.20000000     10       3    cluster        5
68   50 100 0.20000000 0.20000000     10       3    cluster        5
69   50 250 0.20000000 0.20000000     10       3    cluster        5
70  100 100 0.20000000 0.20000000     10       3    cluster       10
71  100 200 0.20000000 0.20000000     10       3    cluster       10
72  100 500 0.20000000 0.20000000     10       3    cluster       10
73   10  10 0.20000000 0.20000000      3      10    cluster        2
74   10  20 0.20000000 0.20000000      3      10    cluster        2
75   10  50 0.20000000 0.20000000      3      10    cluster        2
76   25  25 0.20000000 0.20000000      3      10    cluster        2
77   25  50 0.20000000 0.20000000      3      10    cluster        2
78   25 125 0.20000000 0.20000000      3      10    cluster        2
79   50  50 0.20000000 0.20000000      3      10    cluster        5
80   50 100 0.20000000 0.20000000      3      10    cluster        5
81   50 250 0.20000000 0.20000000      3      10    cluster        5
82  100 100 0.20000000 0.20000000      3      10    cluster       10
83  100 200 0.20000000 0.20000000      3      10    cluster       10
84  100 500 0.20000000 0.20000000      3      10    cluster       10
85   10  10 0.20000000 0.20000000     10      10    cluster        2
86   10  20 0.20000000 0.20000000     10      10    cluster        2
87   10  50 0.20000000 0.20000000     10      10    cluster        2
88   25  25 0.20000000 0.20000000     10      10    cluster        2
89   25  50 0.20000000 0.20000000     10      10    cluster        2
90   25 125 0.20000000 0.20000000     10      10    cluster        2
91   50  50 0.20000000 0.20000000     10      10    cluster        5
92   50 100 0.20000000 0.20000000     10      10    cluster        5
93   50 250 0.20000000 0.20000000     10      10    cluster        5
94  100 100 0.20000000 0.20000000     10      10    cluster       10
95  100 200 0.20000000 0.20000000     10      10    cluster       10
96  100 500 0.20000000 0.20000000     10      10    cluster       10
97   10  10 0.80000000 0.80000000      3       3     random        1
98   10  10 0.80000000 0.50000000      3       3     random        1
99   10  10 0.80000000 0.04081633      3       3     random        1
100  10  10 0.50000000 0.80000000      3       3     random        1
101  10  10 0.50000000 0.50000000      3       3     random        1
102  10  10 0.50000000 0.02020202      3       3     random        1
103  10  10 0.04081633 0.80000000      3       3     random        1
104  10  10 0.04081633 0.50000000      3       3     random        1
105  10  10 0.04081633 0.02020202      3       3     random        1
106  10  20 0.80000000 0.80000000      3       3     random        1
107  10  20 0.80000000 0.50000000      3       3     random        1
108  10  20 0.80000000 0.02020202      3       3     random        1
109  10  20 0.50000000 0.80000000      3       3     random        1
110  10  20 0.50000000 0.50000000      3       3     random        1
111  10  20 0.50000000 0.22222222      3       3     random        1
112  10  20 0.02020202 0.80000000      3       3     random        1
113  10  20 0.02020202 0.50000000      3       3     random        1
114  10  20 0.02020202 0.22222222      3       3     random        1
115  10  50 0.80000000 0.80000000      3       3     random        1
116  10  50 0.80000000 0.50000000      3       3     random        1
117  10  50 0.80000000 0.22222222      3       3     random        1
118  10  50 0.50000000 0.80000000      3       3     random        1
119  10  50 0.50000000 0.50000000      3       3     random        1
120  10  50 0.50000000 0.08333333      3       3     random        1
121  10  50 0.02020202 0.80000000      3       3     random        1
122  10  50 0.02020202 0.50000000      3       3     random        1
123  10  50 0.02020202 0.08333333      3       3     random        1
124  25  25 0.80000000 0.80000000      3       3     random        1
125  25  25 0.80000000 0.50000000      3       3     random        1
126  25  25 0.80000000 0.08333333      3       3     random        1
127  25  25 0.50000000 0.80000000      3       3     random        1
128  25  25 0.50000000 0.50000000      3       3     random        1
129  25  25 0.50000000 0.04081633      3       3     random        1
130  25  25 0.02020202 0.80000000      3       3     random        1
131  25  25 0.02020202 0.50000000      3       3     random        1
132  25  25 0.02020202 0.04081633      3       3     random        1
133  25  50 0.80000000 0.80000000      3       3     random        1
134  25  50 0.80000000 0.50000000      3       3     random        1
135  25  50 0.80000000 0.04081633      3       3     random        1
136  25  50 0.50000000 0.80000000      3       3     random        1
137  25  50 0.50000000 0.50000000      3       3     random        1
138  25  50 0.50000000 0.02020202      3       3     random        1
139  25  50 0.22222222 0.80000000      3       3     random        1
140  25  50 0.22222222 0.50000000      3       3     random        1
141  25  50 0.22222222 0.02020202      3       3     random        1
142  25 125 0.80000000 0.80000000      3       3     random        1
143  25 125 0.80000000 0.50000000      3       3     random        1
144  25 125 0.80000000 0.02020202      3       3     random        1
145  25 125 0.50000000 0.80000000      3       3     random        1
146  25 125 0.50000000 0.50000000      3       3     random        1
147  25 125 0.50000000 0.22222222      3       3     random        1
148  25 125 0.22222222 0.80000000      3       3     random        1
149  25 125 0.22222222 0.50000000      3       3     random        1
150  25 125 0.22222222 0.22222222      3       3     random        1
151  50  50 0.80000000 0.80000000      3       3     random        1
152  50  50 0.80000000 0.50000000      3       3     random        1
153  50  50 0.80000000 0.22222222      3       3     random        1
154  50  50 0.50000000 0.80000000      3       3     random        1
155  50  50 0.50000000 0.50000000      3       3     random        1
156  50  50 0.50000000 0.08333333      3       3     random        1
157  50  50 0.22222222 0.80000000      3       3     random        1
158  50  50 0.22222222 0.50000000      3       3     random        1
159  50  50 0.22222222 0.08333333      3       3     random        1
160  50 100 0.80000000 0.80000000      3       3     random        1
161  50 100 0.80000000 0.50000000      3       3     random        1
162  50 100 0.80000000 0.08333333      3       3     random        1
163  50 100 0.50000000 0.80000000      3       3     random        1
164  50 100 0.50000000 0.50000000      3       3     random        1
165  50 100 0.50000000 0.04081633      3       3     random        1
166  50 100 0.08333333 0.80000000      3       3     random        1
167  50 100 0.08333333 0.50000000      3       3     random        1
168  50 100 0.08333333 0.04081633      3       3     random        1
169  50 250 0.80000000 0.80000000      3       3     random        1
170  50 250 0.80000000 0.50000000      3       3     random        1
171  50 250 0.80000000 0.04081633      3       3     random        1
172  50 250 0.50000000 0.80000000      3       3     random        1
173  50 250 0.50000000 0.50000000      3       3     random        1
174  50 250 0.50000000 0.02020202      3       3     random        1
175  50 250 0.08333333 0.80000000      3       3     random        1
176  50 250 0.08333333 0.50000000      3       3     random        1
177  50 250 0.08333333 0.02020202      3       3     random        1
178 100 100 0.80000000 0.80000000      3       3     random        1
179 100 100 0.80000000 0.50000000      3       3     random        1
180 100 100 0.80000000 0.02020202      3       3     random        1
181 100 100 0.50000000 0.80000000      3       3     random        1
182 100 100 0.50000000 0.50000000      3       3     random        1
183 100 100 0.50000000 0.22222222      3       3     random        1
184 100 100 0.08333333 0.80000000      3       3     random        1
185 100 100 0.08333333 0.50000000      3       3     random        1
186 100 100 0.08333333 0.22222222      3       3     random        1
187 100 200 0.80000000 0.80000000      3       3     random        1
188 100 200 0.80000000 0.50000000      3       3     random        1
189 100 200 0.80000000 0.22222222      3       3     random        1
190 100 200 0.50000000 0.80000000      3       3     random        1
191 100 200 0.50000000 0.50000000      3       3     random        1
192 100 200 0.50000000 0.08333333      3       3     random        1
193 100 200 0.04081633 0.80000000      3       3     random        1
194 100 200 0.04081633 0.50000000      3       3     random        1
195 100 200 0.04081633 0.08333333      3       3     random        1
196 100 500 0.80000000 0.80000000      3       3     random        1
197 100 500 0.80000000 0.50000000      3       3     random        1
198 100 500 0.80000000 0.08333333      3       3     random        1
199 100 500 0.50000000 0.80000000      3       3     random        1
200 100 500 0.50000000 0.50000000      3       3     random        1
201 100 500 0.50000000 0.04081633      3       3     random        1
202 100 500 0.04081633 0.80000000      3       3     random        1
203 100 500 0.04081633 0.50000000      3       3     random        1
204 100 500 0.04081633 0.04081633      3       3     random        1
205  10  10 0.80000000 0.80000000     10       3     random        1
206  10  10 0.80000000 0.50000000     10       3     random        1
207  10  10 0.80000000 0.04081633     10       3     random        1
208  10  10 0.50000000 0.80000000     10       3     random        1
209  10  10 0.50000000 0.50000000     10       3     random        1
210  10  10 0.50000000 0.02020202     10       3     random        1
211  10  10 0.04081633 0.80000000     10       3     random        1
212  10  10 0.04081633 0.50000000     10       3     random        1
213  10  10 0.04081633 0.02020202     10       3     random        1
214  10  20 0.80000000 0.80000000     10       3     random        1
215  10  20 0.80000000 0.50000000     10       3     random        1
216  10  20 0.80000000 0.02020202     10       3     random        1
217  10  20 0.50000000 0.80000000     10       3     random        1
218  10  20 0.50000000 0.50000000     10       3     random        1
219  10  20 0.50000000 0.22222222     10       3     random        1
220  10  20 0.02020202 0.80000000     10       3     random        1
221  10  20 0.02020202 0.50000000     10       3     random        1
222  10  20 0.02020202 0.22222222     10       3     random        1
223  10  50 0.80000000 0.80000000     10       3     random        1
224  10  50 0.80000000 0.50000000     10       3     random        1
225  10  50 0.80000000 0.22222222     10       3     random        1
226  10  50 0.50000000 0.80000000     10       3     random        1
227  10  50 0.50000000 0.50000000     10       3     random        1
228  10  50 0.50000000 0.08333333     10       3     random        1
229  10  50 0.02020202 0.80000000     10       3     random        1
230  10  50 0.02020202 0.50000000     10       3     random        1
231  10  50 0.02020202 0.08333333     10       3     random        1
232  25  25 0.80000000 0.80000000     10       3     random        1
233  25  25 0.80000000 0.50000000     10       3     random        1
234  25  25 0.80000000 0.08333333     10       3     random        1
235  25  25 0.50000000 0.80000000     10       3     random        1
236  25  25 0.50000000 0.50000000     10       3     random        1
237  25  25 0.50000000 0.04081633     10       3     random        1
238  25  25 0.02020202 0.80000000     10       3     random        1
239  25  25 0.02020202 0.50000000     10       3     random        1
240  25  25 0.02020202 0.04081633     10       3     random        1
241  25  50 0.80000000 0.80000000     10       3     random        1
242  25  50 0.80000000 0.50000000     10       3     random        1
243  25  50 0.80000000 0.04081633     10       3     random        1
244  25  50 0.50000000 0.80000000     10       3     random        1
245  25  50 0.50000000 0.50000000     10       3     random        1
246  25  50 0.50000000 0.02020202     10       3     random        1
247  25  50 0.22222222 0.80000000     10       3     random        1
248  25  50 0.22222222 0.50000000     10       3     random        1
249  25  50 0.22222222 0.02020202     10       3     random        1
250  25 125 0.80000000 0.80000000     10       3     random        1
251  25 125 0.80000000 0.50000000     10       3     random        1
252  25 125 0.80000000 0.02020202     10       3     random        1
253  25 125 0.50000000 0.80000000     10       3     random        1
254  25 125 0.50000000 0.50000000     10       3     random        1
255  25 125 0.50000000 0.22222222     10       3     random        1
256  25 125 0.22222222 0.80000000     10       3     random        1
257  25 125 0.22222222 0.50000000     10       3     random        1
258  25 125 0.22222222 0.22222222     10       3     random        1
259  50  50 0.80000000 0.80000000     10       3     random        1
260  50  50 0.80000000 0.50000000     10       3     random        1
261  50  50 0.80000000 0.22222222     10       3     random        1
262  50  50 0.50000000 0.80000000     10       3     random        1
263  50  50 0.50000000 0.50000000     10       3     random        1
264  50  50 0.50000000 0.08333333     10       3     random        1
265  50  50 0.22222222 0.80000000     10       3     random        1
266  50  50 0.22222222 0.50000000     10       3     random        1
267  50  50 0.22222222 0.08333333     10       3     random        1
268  50 100 0.80000000 0.80000000     10       3     random        1
269  50 100 0.80000000 0.50000000     10       3     random        1
270  50 100 0.80000000 0.08333333     10       3     random        1
271  50 100 0.50000000 0.80000000     10       3     random        1
272  50 100 0.50000000 0.50000000     10       3     random        1
273  50 100 0.50000000 0.04081633     10       3     random        1
274  50 100 0.08333333 0.80000000     10       3     random        1
275  50 100 0.08333333 0.50000000     10       3     random        1
276  50 100 0.08333333 0.04081633     10       3     random        1
277  50 250 0.80000000 0.80000000     10       3     random        1
278  50 250 0.80000000 0.50000000     10       3     random        1
279  50 250 0.80000000 0.04081633     10       3     random        1
280  50 250 0.50000000 0.80000000     10       3     random        1
281  50 250 0.50000000 0.50000000     10       3     random        1
282  50 250 0.50000000 0.02020202     10       3     random        1
283  50 250 0.08333333 0.80000000     10       3     random        1
284  50 250 0.08333333 0.50000000     10       3     random        1
285  50 250 0.08333333 0.02020202     10       3     random        1
286 100 100 0.80000000 0.80000000     10       3     random        1
287 100 100 0.80000000 0.50000000     10       3     random        1
288 100 100 0.80000000 0.02020202     10       3     random        1
289 100 100 0.50000000 0.80000000     10       3     random        1
290 100 100 0.50000000 0.50000000     10       3     random        1
291 100 100 0.50000000 0.22222222     10       3     random        1
292 100 100 0.08333333 0.80000000     10       3     random        1
293 100 100 0.08333333 0.50000000     10       3     random        1
294 100 100 0.08333333 0.22222222     10       3     random        1
295 100 200 0.80000000 0.80000000     10       3     random        1
296 100 200 0.80000000 0.50000000     10       3     random        1
297 100 200 0.80000000 0.22222222     10       3     random        1
298 100 200 0.50000000 0.80000000     10       3     random        1
299 100 200 0.50000000 0.50000000     10       3     random        1
300 100 200 0.50000000 0.08333333     10       3     random        1
301 100 200 0.04081633 0.80000000     10       3     random        1
302 100 200 0.04081633 0.50000000     10       3     random        1
303 100 200 0.04081633 0.08333333     10       3     random        1
304 100 500 0.80000000 0.80000000     10       3     random        1
305 100 500 0.80000000 0.50000000     10       3     random        1
306 100 500 0.80000000 0.08333333     10       3     random        1
307 100 500 0.50000000 0.80000000     10       3     random        1
308 100 500 0.50000000 0.50000000     10       3     random        1
309 100 500 0.50000000 0.04081633     10       3     random        1
310 100 500 0.04081633 0.80000000     10       3     random        1
311 100 500 0.04081633 0.50000000     10       3     random        1
312 100 500 0.04081633 0.04081633     10       3     random        1
313  10  10 0.80000000 0.80000000      3      10     random        1
314  10  10 0.80000000 0.50000000      3      10     random        1
315  10  10 0.80000000 0.04081633      3      10     random        1
316  10  10 0.50000000 0.80000000      3      10     random        1
317  10  10 0.50000000 0.50000000      3      10     random        1
318  10  10 0.50000000 0.02020202      3      10     random        1
319  10  10 0.04081633 0.80000000      3      10     random        1
320  10  10 0.04081633 0.50000000      3      10     random        1
321  10  10 0.04081633 0.02020202      3      10     random        1
322  10  20 0.80000000 0.80000000      3      10     random        1
323  10  20 0.80000000 0.50000000      3      10     random        1
324  10  20 0.80000000 0.02020202      3      10     random        1
325  10  20 0.50000000 0.80000000      3      10     random        1
326  10  20 0.50000000 0.50000000      3      10     random        1
327  10  20 0.50000000 0.22222222      3      10     random        1
328  10  20 0.02020202 0.80000000      3      10     random        1
329  10  20 0.02020202 0.50000000      3      10     random        1
330  10  20 0.02020202 0.22222222      3      10     random        1
331  10  50 0.80000000 0.80000000      3      10     random        1
332  10  50 0.80000000 0.50000000      3      10     random        1
333  10  50 0.80000000 0.22222222      3      10     random        1
334  10  50 0.50000000 0.80000000      3      10     random        1
335  10  50 0.50000000 0.50000000      3      10     random        1
336  10  50 0.50000000 0.08333333      3      10     random        1
337  10  50 0.02020202 0.80000000      3      10     random        1
338  10  50 0.02020202 0.50000000      3      10     random        1
339  10  50 0.02020202 0.08333333      3      10     random        1
340  25  25 0.80000000 0.80000000      3      10     random        1
341  25  25 0.80000000 0.50000000      3      10     random        1
342  25  25 0.80000000 0.08333333      3      10     random        1
343  25  25 0.50000000 0.80000000      3      10     random        1
344  25  25 0.50000000 0.50000000      3      10     random        1
345  25  25 0.50000000 0.04081633      3      10     random        1
346  25  25 0.02020202 0.80000000      3      10     random        1
347  25  25 0.02020202 0.50000000      3      10     random        1
348  25  25 0.02020202 0.04081633      3      10     random        1
349  25  50 0.80000000 0.80000000      3      10     random        1
350  25  50 0.80000000 0.50000000      3      10     random        1
351  25  50 0.80000000 0.04081633      3      10     random        1
352  25  50 0.50000000 0.80000000      3      10     random        1
353  25  50 0.50000000 0.50000000      3      10     random        1
354  25  50 0.50000000 0.02020202      3      10     random        1
355  25  50 0.22222222 0.80000000      3      10     random        1
356  25  50 0.22222222 0.50000000      3      10     random        1
357  25  50 0.22222222 0.02020202      3      10     random        1
358  25 125 0.80000000 0.80000000      3      10     random        1
359  25 125 0.80000000 0.50000000      3      10     random        1
360  25 125 0.80000000 0.02020202      3      10     random        1
361  25 125 0.50000000 0.80000000      3      10     random        1
362  25 125 0.50000000 0.50000000      3      10     random        1
363  25 125 0.50000000 0.22222222      3      10     random        1
364  25 125 0.22222222 0.80000000      3      10     random        1
365  25 125 0.22222222 0.50000000      3      10     random        1
366  25 125 0.22222222 0.22222222      3      10     random        1
367  50  50 0.80000000 0.80000000      3      10     random        1
368  50  50 0.80000000 0.50000000      3      10     random        1
369  50  50 0.80000000 0.22222222      3      10     random        1
370  50  50 0.50000000 0.80000000      3      10     random        1
371  50  50 0.50000000 0.50000000      3      10     random        1
372  50  50 0.50000000 0.08333333      3      10     random        1
373  50  50 0.22222222 0.80000000      3      10     random        1
374  50  50 0.22222222 0.50000000      3      10     random        1
375  50  50 0.22222222 0.08333333      3      10     random        1
376  50 100 0.80000000 0.80000000      3      10     random        1
377  50 100 0.80000000 0.50000000      3      10     random        1
378  50 100 0.80000000 0.08333333      3      10     random        1
379  50 100 0.50000000 0.80000000      3      10     random        1
380  50 100 0.50000000 0.50000000      3      10     random        1
381  50 100 0.50000000 0.04081633      3      10     random        1
382  50 100 0.08333333 0.80000000      3      10     random        1
383  50 100 0.08333333 0.50000000      3      10     random        1
384  50 100 0.08333333 0.04081633      3      10     random        1
385  50 250 0.80000000 0.80000000      3      10     random        1
386  50 250 0.80000000 0.50000000      3      10     random        1
387  50 250 0.80000000 0.04081633      3      10     random        1
388  50 250 0.50000000 0.80000000      3      10     random        1
389  50 250 0.50000000 0.50000000      3      10     random        1
390  50 250 0.50000000 0.02020202      3      10     random        1
391  50 250 0.08333333 0.80000000      3      10     random        1
392  50 250 0.08333333 0.50000000      3      10     random        1
393  50 250 0.08333333 0.02020202      3      10     random        1
394 100 100 0.80000000 0.80000000      3      10     random        1
395 100 100 0.80000000 0.50000000      3      10     random        1
396 100 100 0.80000000 0.02020202      3      10     random        1
397 100 100 0.50000000 0.80000000      3      10     random        1
398 100 100 0.50000000 0.50000000      3      10     random        1
399 100 100 0.50000000 0.22222222      3      10     random        1
400 100 100 0.08333333 0.80000000      3      10     random        1
401 100 100 0.08333333 0.50000000      3      10     random        1
402 100 100 0.08333333 0.22222222      3      10     random        1
403 100 200 0.80000000 0.80000000      3      10     random        1
404 100 200 0.80000000 0.50000000      3      10     random        1
405 100 200 0.80000000 0.22222222      3      10     random        1
406 100 200 0.50000000 0.80000000      3      10     random        1
407 100 200 0.50000000 0.50000000      3      10     random        1
408 100 200 0.50000000 0.08333333      3      10     random        1
409 100 200 0.04081633 0.80000000      3      10     random        1
410 100 200 0.04081633 0.50000000      3      10     random        1
411 100 200 0.04081633 0.08333333      3      10     random        1
412 100 500 0.80000000 0.80000000      3      10     random        1
413 100 500 0.80000000 0.50000000      3      10     random        1
414 100 500 0.80000000 0.08333333      3      10     random        1
415 100 500 0.50000000 0.80000000      3      10     random        1
416 100 500 0.50000000 0.50000000      3      10     random        1
417 100 500 0.50000000 0.04081633      3      10     random        1
418 100 500 0.04081633 0.80000000      3      10     random        1
419 100 500 0.04081633 0.50000000      3      10     random        1
420 100 500 0.04081633 0.04081633      3      10     random        1
421  10  10 0.80000000 0.80000000     10      10     random        1
422  10  10 0.80000000 0.50000000     10      10     random        1
423  10  10 0.80000000 0.04081633     10      10     random        1
424  10  10 0.50000000 0.80000000     10      10     random        1
425  10  10 0.50000000 0.50000000     10      10     random        1
426  10  10 0.50000000 0.02020202     10      10     random        1
427  10  10 0.04081633 0.80000000     10      10     random        1
428  10  10 0.04081633 0.50000000     10      10     random        1
429  10  10 0.04081633 0.02020202     10      10     random        1
430  10  20 0.80000000 0.80000000     10      10     random        1
431  10  20 0.80000000 0.50000000     10      10     random        1
432  10  20 0.80000000 0.02020202     10      10     random        1
433  10  20 0.50000000 0.80000000     10      10     random        1
434  10  20 0.50000000 0.50000000     10      10     random        1
435  10  20 0.50000000 0.22222222     10      10     random        1
436  10  20 0.02020202 0.80000000     10      10     random        1
437  10  20 0.02020202 0.50000000     10      10     random        1
438  10  20 0.02020202 0.22222222     10      10     random        1
439  10  50 0.80000000 0.80000000     10      10     random        1
440  10  50 0.80000000 0.50000000     10      10     random        1
441  10  50 0.80000000 0.22222222     10      10     random        1
442  10  50 0.50000000 0.80000000     10      10     random        1
443  10  50 0.50000000 0.50000000     10      10     random        1
444  10  50 0.50000000 0.08333333     10      10     random        1
445  10  50 0.02020202 0.80000000     10      10     random        1
446  10  50 0.02020202 0.50000000     10      10     random        1
447  10  50 0.02020202 0.08333333     10      10     random        1
448  25  25 0.80000000 0.80000000     10      10     random        1
449  25  25 0.80000000 0.50000000     10      10     random        1
450  25  25 0.80000000 0.08333333     10      10     random        1
451  25  25 0.50000000 0.80000000     10      10     random        1
452  25  25 0.50000000 0.50000000     10      10     random        1
453  25  25 0.50000000 0.04081633     10      10     random        1
454  25  25 0.02020202 0.80000000     10      10     random        1
455  25  25 0.02020202 0.50000000     10      10     random        1
456  25  25 0.02020202 0.04081633     10      10     random        1
457  25  50 0.80000000 0.80000000     10      10     random        1
458  25  50 0.80000000 0.50000000     10      10     random        1
459  25  50 0.80000000 0.04081633     10      10     random        1
460  25  50 0.50000000 0.80000000     10      10     random        1
461  25  50 0.50000000 0.50000000     10      10     random        1
462  25  50 0.50000000 0.02020202     10      10     random        1
463  25  50 0.22222222 0.80000000     10      10     random        1
464  25  50 0.22222222 0.50000000     10      10     random        1
465  25  50 0.22222222 0.02020202     10      10     random        1
466  25 125 0.80000000 0.80000000     10      10     random        1
467  25 125 0.80000000 0.50000000     10      10     random        1
468  25 125 0.80000000 0.02020202     10      10     random        1
469  25 125 0.50000000 0.80000000     10      10     random        1
470  25 125 0.50000000 0.50000000     10      10     random        1
471  25 125 0.50000000 0.22222222     10      10     random        1
472  25 125 0.22222222 0.80000000     10      10     random        1
473  25 125 0.22222222 0.50000000     10      10     random        1
474  25 125 0.22222222 0.22222222     10      10     random        1
475  50  50 0.80000000 0.80000000     10      10     random        1
476  50  50 0.80000000 0.50000000     10      10     random        1
477  50  50 0.80000000 0.22222222     10      10     random        1
478  50  50 0.50000000 0.80000000     10      10     random        1
479  50  50 0.50000000 0.50000000     10      10     random        1
480  50  50 0.50000000 0.08333333     10      10     random        1
481  50  50 0.22222222 0.80000000     10      10     random        1
482  50  50 0.22222222 0.50000000     10      10     random        1
483  50  50 0.22222222 0.08333333     10      10     random        1
484  50 100 0.80000000 0.80000000     10      10     random        1
485  50 100 0.80000000 0.50000000     10      10     random        1
486  50 100 0.80000000 0.08333333     10      10     random        1
487  50 100 0.50000000 0.80000000     10      10     random        1
488  50 100 0.50000000 0.50000000     10      10     random        1
489  50 100 0.50000000 0.04081633     10      10     random        1
490  50 100 0.08333333 0.80000000     10      10     random        1
491  50 100 0.08333333 0.50000000     10      10     random        1
492  50 100 0.08333333 0.04081633     10      10     random        1
493  50 250 0.80000000 0.80000000     10      10     random        1
494  50 250 0.80000000 0.50000000     10      10     random        1
495  50 250 0.80000000 0.04081633     10      10     random        1
496  50 250 0.50000000 0.80000000     10      10     random        1
497  50 250 0.50000000 0.50000000     10      10     random        1
498  50 250 0.50000000 0.02020202     10      10     random        1
499  50 250 0.08333333 0.80000000     10      10     random        1
500  50 250 0.08333333 0.50000000     10      10     random        1
501  50 250 0.08333333 0.02020202     10      10     random        1
502 100 100 0.80000000 0.80000000     10      10     random        1
503 100 100 0.80000000 0.50000000     10      10     random        1
504 100 100 0.80000000 0.02020202     10      10     random        1
505 100 100 0.50000000 0.80000000     10      10     random        1
506 100 100 0.50000000 0.50000000     10      10     random        1
507 100 100 0.50000000 0.22222222     10      10     random        1
508 100 100 0.08333333 0.80000000     10      10     random        1
509 100 100 0.08333333 0.50000000     10      10     random        1
510 100 100 0.08333333 0.22222222     10      10     random        1
511 100 200 0.80000000 0.80000000     10      10     random        1
512 100 200 0.80000000 0.50000000     10      10     random        1
513 100 200 0.80000000 0.22222222     10      10     random        1
514 100 200 0.50000000 0.80000000     10      10     random        1
515 100 200 0.50000000 0.50000000     10      10     random        1
516 100 200 0.50000000 0.08333333     10      10     random        1
517 100 200 0.04081633 0.80000000     10      10     random        1
518 100 200 0.04081633 0.50000000     10      10     random        1
519 100 200 0.04081633 0.08333333     10      10     random        1
520 100 500 0.80000000 0.80000000     10      10     random        1
521 100 500 0.80000000 0.50000000     10      10     random        1
522 100 500 0.80000000 0.08333333     10      10     random        1
523 100 500 0.50000000 0.80000000     10      10     random        1
524 100 500 0.50000000 0.50000000     10      10     random        1
525 100 500 0.50000000 0.04081633     10      10     random        1
526 100 500 0.04081633 0.80000000     10      10     random        1
527 100 500 0.04081633 0.50000000     10      10     random        1
528 100 500 0.04081633 0.04081633     10      10     random        1
> for (i in 1:nrow(conditions_grid)) {
+ params <- conditions_grid[i, ]
+   print(params)
+ for (rep in 1:reps) {
+ cat(paste("\nCondition", i, "| Repetition", rep, "of", reps, "\n"))
+ data  <-  bdgraph.sim(
+       p = params$p,
+       graph = params$graph_type,
+       n = params$n,
+       type = "Gaussian",
+       prob = params$true_g,
+       b = params$true_b,
+       class = params$clusters
+     )
+ G_true <- data$G
+     K_true <- data$K
+ # --- 2.2. Run the BDMCMC Algorithm ---
+     sample_bd <- bdgraph(
+       data = data$data,
+       algorithm = "bdmcmc",
+       iter = 5000,
+       g.prior = params$prior_g,
+       df.prior = params$prior_b,
+       save = TRUE
+     )
+ summary_bd <- summary(sample_bd, round = 3, vis = FALSE)
+ # Extract estimated G and K
+     pip_edge <- summary_bd$p_links
+     G_est <- summary_bd$selected_g
+     K_est <-  sample_bd$K_hat
+ # -- 3.1. Graph Structure Recovery Metrics --
+     true_vec <- G_true[upper.tri(G_true)]
+     est_vec <- G_est[upper.tri(G_est)]
+     prob_vec <- pip_edge[upper.tri(pip_edge)]
+ TP <- sum(est_vec == 1 & true_vec == 1)
+     FP <- sum(est_vec == 1 & true_vec == 0)
+     TN <- sum(est_vec == 0 & true_vec == 0)
+     FN <- sum(est_vec == 0 & true_vec == 1)
+ sensitivity <- ifelse((TP + FN) == 0, 0, TP / (TP + FN))
+     specificity <- ifelse((TN + FP) == 0, 0, TN / (TN + FP))
+     precision   <- ifelse((TP + FP) == 0, 0, TP / (TP + FP))
+     f1_score    <- ifelse((precision + sensitivity) == 0, 0,
+                           2 * (precision * sensitivity) / (precision + sensitivity))
+ roc_obj <- BDgraph::roc(pred = sample_bd, actual = data, auc = TRUE)
+     auc_val <- as.numeric(roc_obj$auc)
+ # -- 3.2. Precision Matrix Estimation Metrics --
+     diff_K <- K_est - K_true
+     frobenius_norm <- norm(diff_K, type = "F")
+     spectral_norm  <- norm(diff_K, type = "2")
+     rmse <- sqrt(mean(diff_K^2))
+ # -- 3.3. Node Strength Difference Metric --
+     strength_true <- get_strength(G_true, K_true)
+     strength_est  <- get_strength(G_est, K_est)
+     strength_mae <- mean(abs(strength_est - strength_true))
+ # -- 3.4. Magnitude of Probability Metrics (NEW) --
+     p_plus <- ifelse(sum(true_vec) == 0, 0, mean(prob_vec[true_vec == 1]))
+     p_minus <- ifelse(sum(true_vec == 0) == 0, 0, mean(prob_vec[true_vec == 0]))
+ # --- 4. STORE RESULTS ---
+     current_run_results <- data.frame(
+       condition_id = i, rep = rep, p = params$p,
+       n = params$n, graph_type = params$graph_type,
+       g_prior = params$prior_g, g_true = params$true_g,
+       b_prior = params$prior_b, b_true = params$true_b,
+       size = params$clusters,
+       sensitivity = sensitivity, specificity = specificity,
+       precision = precision, f1_score = f1_score, auc = auc_val,
+       p_plus = p_plus, p_minus = p_minus,
+       frobenius_norm = frobenius_norm, spectral_norm = spectral_norm,
+       rmse = rmse, strength_mae = strength_mae
+     )
+ results_df <- rbind(results_df, current_run_results)
+     filename <- paste0("out/results_", i, ".rds")
+     if (i %% 24 == 0) saveRDS(filename)
+ cat("\n")
+ }
+ }
+    p  n true_g prior_g true_b prior_b graph_type clusters
1 10 10    0.2     0.2      3       3 scale-free        1

Condition 1 | Repetition 1 of 5 
5000 MCMC sampling ... in progress: 
10%->20%->30%->40%->50%->60%->70%->80%->90%-> done

Condition 1 | Repetition 2 of 5 
5000 MCMC sampling ... in progress: 
10%->20%->30%->40%->50%->60%->70%->80%->90%-> done

Condition 1 | Repetition 3 of 5 
5000 MCMC sampling ... in progress: 
10%->20%->30%->40%->50%->60%->70%->80%->90%-> done

Condition 1 | Repetition 4 of 5 
5000 MCMC sampling ... in progress: 
10%->20%->30%->40%->50%->60%->70%->80%->90%-> done

Condition 1 | Repetition 5 of 5 
5000 MCMC sampling ... in progress: 
10%->20%->30%->40%->50%->60%->70%->80%->90%-> done
   p  n true_g prior_g true_b prior_b graph_type clusters
2 10 20    0.2     0.2      3       3 scale-free        1

Condition 2 | Repetition 1 of 5 
5000 MCMC sampling ... in progress: 
10%->20%->30%->40%->50%->60%->70%->80%->90%-> done

Condition 2 | Repetition 2 of 5 
5000 MCMC sampling ... in progress: 
10%->20%->30%->40%->50%->60%->70%->80%->90%-> done

Condition 2 | Repetition 3 of 5 
5000 MCMC sampling ... in progress: 
10%->20%->30%->40%->50%->60%->70%->80%->90%-> done

Condition 2 | Repetition 4 of 5 
5000 MCMC sampling ... in progress: 
10%->20%->30%->40%->50%->60%->70%->80%->90%-> done

Condition 2 | Repetition 5 of 5 
5000 MCMC sampling ... in progress: 
10%->20%->30%->40%->50%->60%->70%->80%->90%-> done
   p  n true_g prior_g true_b prior_b graph_type clusters
3 10 50    0.2     0.2      3       3 scale-free        1

Condition 3 | Repetition 1 of 5 
5000 MCMC sampling ... in progress: 
10%->20%->30%->40%->50%->60%->70%->80%->90%-> done

Condition 3 | Repetition 2 of 5 
5000 MCMC sampling ... in progress: 
10%->20%->30%->40%->50%->60%->70%->80%->90%-> done

Condition 3 | Repetition 3 of 5 
5000 MCMC sampling ... in progress: 
10%->20%->30%->40%->50%->60%->70%->80%->90%-> done

Condition 3 | Repetition 4 of 5 
5000 MCMC sampling ... in progress: 
10%->20%->30%->40%->50%->60%->70%->80%->90%-> done

Condition 3 | Repetition 5 of 5 
5000 MCMC sampling ... in progress: 
10%->20%->30%->40%->50%->60%->70%->80%->90%-> done
   p  n true_g prior_g true_b prior_b graph_type clusters
4 25 25    0.2     0.2      3       3 scale-free        1

Condition 4 | Repetition 1 of 5 
5000 MCMC sampling ... in progress: 
10%->20%->30%->40%->50%->60%->70%->80%->90%-> done

Condition 4 | Repetition 2 of 5 
5000 MCMC sampling ... in progress: 
10%->20%->30%->40%->50%->60%->70%->80%->90%-> done

Condition 4 | Repetition 3 of 5 
5000 MCMC sampling ... in progress: 
10%->20%->30%->40%->50%->60%->70%->80%->90%-> done

Condition 4 | Repetition 4 of 5 
5000 MCMC sampling ... in progress: 
10%->20%->30%->40%->50%->60%->70%->80%->90%-> done

Condition 4 | Repetition 5 of 5 
5000 MCMC sampling ... in progress: 
10%->20%->30%->40%->50%->60%->70%->80%->90%-> done
   p  n true_g prior_g true_b prior_b graph_type clusters
5 25 50    0.2     0.2      3       3 scale-free        1

Condition 5 | Repetition 1 of 5 
5000 MCMC sampling ... in progress: 
10%->20%->30%->40%->50%->60%->70%->80%->90%-> done

Condition 5 | Repetition 2 of 5 
5000 MCMC sampling ... in progress: 
10%->20%->30%->40%->50%->60%->70%->80%->90%-> done

Condition 5 | Repetition 3 of 5 
5000 MCMC sampling ... in progress: 
10%->20%->30%->40%->50%->60%->70%->80%->90%->  C-c C-c done
> 
