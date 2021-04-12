function this = calcstats(this)

[this.stat.mean this.stat.max this.stat.min this.stat.std this.stat.variance] = tom_dev(this.image.Value,'noinfo');