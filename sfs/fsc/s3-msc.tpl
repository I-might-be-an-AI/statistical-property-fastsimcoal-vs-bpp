//Parameters for the coalescence simulation program : simcoal.exe
3 samples to simulate :
//Population sizes
NA 
NB
NC
//Sample sizes and ages
10
10
10
//Growth rates: negative growth implies population expansion
0
0
0
//nummber of migration matrices : 0 implies no migration between demes
0
//historical event: time, source, sink, migrants, new deme size, growth rate, migr mat index
2 historical event
tauS 1 0 1 rS 0 0
tauR 2 0 1 rR 0 0
//number of independent loci [chromosome]
500 0
//Per chromosome: number of contiguous linkage Block: a block is a set of contiguous loci
1
//per Block:data type, number of sites, per gen recomb and mut rates
FREQ 1 0 2e-8 OUTEXP
