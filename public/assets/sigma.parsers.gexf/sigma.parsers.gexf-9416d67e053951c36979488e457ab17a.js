(function(){"use strict";function e(){return"e"+i++}if("undefined"==typeof sigma)throw"sigma is not declared";sigma.utils.pkg("sigma.parsers");var i=0;sigma.parsers.gexf=function(i,o,t){function s(i){for(f=i.nodes,r=0,n=f.length;n>r;r++)g=f[r],g.id=g.id,g.viz&&"object"==typeof g.viz&&(g.viz.position&&"object"==typeof g.viz.position&&(g.x=g.viz.position.x,g.y=g.viz.position.y),g.size=g.viz.size,g.color=g.viz.color);for(f=i.edges,r=0,n=f.length;n>r;r++)g=f[r],g.id="string"==typeof g.id?g.id:e(),g.source=""+g.source,g.target=""+g.target,g.viz&&"object"==typeof g.viz&&(g.color=g.viz.color,g.size=g.viz.thickness),g.size=g.weight;if(o instanceof sigma){for(o.graph.clear(),f=i.nodes,r=0,n=f.length;n>r;r++)o.graph.addNode(f[r]);for(f=i.edges,r=0,n=f.length;n>r;r++)o.graph.addEdge(f[r])}else"object"==typeof o?(o.graph=i,o=new sigma(o)):"function"==typeof o&&(t=o,o=null);return t?void t(o||i):i}var r,n,f,g;if("string"==typeof i)gexf.fetch(i,s);else if("object"==typeof i)return s(gexf.parse(i))}}).call(this);