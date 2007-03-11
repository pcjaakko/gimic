#!/usr/bin/env python2.2
#
# This is a _HUGE_ mess... I'll clean it up when I feel like it.
#
# $Id$
#

import sys, string, re
sys.path.append('/home/jonas/lib/python')
import QCTools
from Elements import PeriodicTable as PTab

l_map={'s':0, 'p':1, 'd':2, 'f':3, 'g':4, 'h':5, 'i':6} 

header="""INTGRL        1    0    1    0    0    0    0    0    0
TURBOMOLE
              Generated by turbo2mol (TM)
%i    0            0.10E-08              0    0
9999.00      3.00"""

def main():
	atoms=QCTools.readCoord('coord')
	basis={}
	clist=readbasis('basis')
	for i in clist:
		basis[i.symbol]=i

	print header % (len(atoms)-1)
	for i in range(1,len(atoms)):
		a=atoms[i]
		sym=string.upper(a.element.symbol)
		b=basis[sym]
		print float(a.element.number),'  ', 1, b 
		print "%2c%2i%20.12f%20.12f%20.12f" % \
			(sym, 1, a.coord[0], a.coord[1], a.coord[2])
		for c in b.ctr_list:
			print c,

class AOBasis(object):
	"Basis set holder for one atom"
	def __init__(self, symbol):
		self.symbol=symbol
		self.lmax=1
		self.nshells=[0]
		self.ctr_list=[]
	
	def add(self, ctr):
		l=ctr.l
		if self.lmax < l+1:
			self.lmax=l+1
			self.nshells.append(0)
		self.nshells[l]+=1
		self.ctr_list.append(ctr)

	def __str__(self):
		s=str(self.lmax)+'  '
		for i in self.nshells:
			s+=str(i)+'  '
		return s

class Contraction(object):
	def __init__(self, npf, l, xp, cc):
		self.npf=npf
		self.l=l
		self.xp=xp
		self.cc=cc

	def __str__(self):
		s='%6i'+'  1\n' 
		for i in range(len(self.xp)):
			tmp='%18.10f %15.10f' % (self.xp[i], self.cc[i])
			s+=tmp+'\n'
		return s % self.npf

def readbasis(file):
	f=open(file,'r')
	ll=f.readlines()
	f.close()
	elmt_def=re.compile('([a-zA-Z]{1,2}) .*')
	seg_def=re.compile('([1-9]*) *(s|p|d|f|g|h|i)$')
	
	# some sanity, thank you...
	ll=map(string.strip,ll)
	ll=filter(len,ll)
	
	clist=[]
	i=0
	atm=-1
	while i < len(ll):
		mob=elmt_def.match(ll[i])
		if mob: 
			e=mob.group(1)
			clist.append(AOBasis(string.upper(e)))
			atm+=1
			i+=1
		mob=seg_def.match(ll[i])
		if mob:
			ncomp=int(mob.group(1))
			lqnum=l_map[mob.group(2)]
			i+=1
			xp=[]
			cc=[]
			for j in range(i,ncomp+i):
				(xp1,cc1)=string.split(ll[j])
				xp.append(xp1)
				cc.append(cc1)
			xp=map(float,xp)
			cc=map(float,cc)
			i+=ncomp
			ctr=Contraction(ncomp, lqnum, xp, cc)
			clist[atm].add(ctr)
		else:
			i+=1
	return clist

if __name__ == '__main__':
	main()