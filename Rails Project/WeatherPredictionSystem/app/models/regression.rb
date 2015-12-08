require 'matrix'

class Regression < ActiveRecord::Base


	def self.polyReg(x,y,degree)
	 	x_data=x.map{|x_i|(0..degree).map{|pow|(x_i**pow).to_f}}
	 	mx=Matrix[*x_data]
	 	my=Matrix.column_vector(y)
	 	coefficients=((mx.t*mx).inv*mx.t*my).transpose.to_a[0]

	  return coefficients
	end

	def self.getRsqr(x,y,co)

	  yAvg=y.inject{|r,a|r+a}.to_f/y.size

	  yEst=[]

	  for i in (0..x.length-1)
	    ye=getEstimate(x[i],co)
	    yEst<<ye
	  end

	  ssr=0
	  sst=0

	  for i in (0..y.length-1)
	    ssr+=(yEst[i]-yAvg)**2
	    sst+=(y[i]-yAvg)**2
	  end

	  return ssr/sst
	end

	def self.getEstimate(x,co)
		es=0
		for j in (0..co.length-1)
	      es+=co[j]*x**j
	    end
	    return es
	end

	def self.predictValueProbability(x,y,now,period)
		a=x[0]
		x=x.map{|x|x-a}
		co=self.polyReg(x,y,1)
		probablity=self.getRsqr(x,y,co).round(2)
		px=now.to_i+period.to_i*60-a
		py=self.getEstimate(px,co).round(1)
		return {:predictValue=>py,:probablity=>probablity}
	end

end
