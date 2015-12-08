require 'csv'
require 'matrix'
require 'linefit'

  # The class "Project1" aims to take an txt file as input and calculate different regressions (linear, polynomial,
  # logarithms and exponential) and the goodness of fit of different regressions based on the data  generated from
  # input file.

class Project1

  #The class Project include 4 instance variable.

  def initialize
    @file=ARGV[0] # @file is the file to be calculated from first input from the command line
    @type=ARGV[1] # @type is the type of regression from second input from the command line
    @x_array=[]   # @x_array is the first column of data from the file
    @y_array=[]   # @y_array is the second column of data from the file
  end

  # Function 'file_to_array' generates two arrays of data from the file. Here uses the gem 'csv' and 'matrix'.

  def file_to_array

    CSV.foreach(@file) do |row|
      @x_array<<row[0]
      @y_array<<row[1]
    end

    @x_array.delete_at(0)
    @y_array.delete_at(0)

    @x_array=@x_array.map{|ele| ele.to_f.round(2)}
    @y_array=@y_array.map{|ele| ele.to_f.round(2)}

  end

  # Function 'co_poly' calculates the coefficients of polynomial regression of given 'degree'.

  def co_poly(degree)

    x_data=@x_array.map{|x_i|(0..degree).map{|pow|(x_i**pow).to_f}}
    mx=Matrix[*x_data]
    my=Matrix.column_vector(@y_array)
    coefficients=((mx.t*mx).inv*mx.t*my).transpose.to_a[0]

    return coefficients.map{|ele| ele.round(2)}

  end

  # Function 'var_poly' calculates the variance (RSS) of polynomial regression of given 'degree'.

  def var_poly(degree)

    # The two nesting "for loops" gets the predicted "y" value by the polynomial regression of given 'degree'
    # and gets the sum of squaring of the differences between "predicted y" and y in the file.

    var=0
    for i in (0..@x_array.length-1)
      ye=0
      for j in (0..degree)
        ye+=co_poly(degree)[j]*@x_array[i]**j
      end
      var+=(@y_array[i]-ye)**2
    end

    return var.round(2)

  end

  # Function 'opt_poly_degree' calculates the optimal degree of polynomial regression from 2 to 10.

  def opt_poly_degree

    min=var_poly(2) # 'min' is initialized the variance of degree 2
    opt_degree=2    # 'opt_degree' is initialized degree 2

    # This 'for loop' gets the smallest variance and the corresponding degree.

    for i in (3..10)
      if var_poly(i)<min
        min=var_poly(i)
        opt_degree=i
      end
    end

    return opt_degree
  end

  # Function 'put_opt_poly' print the formula of polynomial regression of optimal degree.

  def put_opt_poly

    de_opt=opt_poly_degree
    co_opt=co_poly(de_opt).reverse   # Reverse the coefficients make them from higher power of terms to lower power.
    print "#{co_opt[0]}x^#{de_opt} " # Print the highest power of term.
    i=1
    while i<=de_opt-2                # This 'while' loop print the following terms without the 'x' and constant terms.
      print "+ #{co_opt[i]}x^#{de_opt-i} "
      i+=1
    end

    print "+ #{co_opt[de_opt-1]}x + #{co_opt[de_opt]}" # Finally print the last two terms.

    puts "" # All the outputs above are 'print', here use a empty 'puts' to change line.

  end

  # Function 'co_log' gets the coefficients of logarithms regression y=a+b*ln(x).

  def co_log
    n=@x_array.length
    sum1=0
    for i in (0..n-1)
      sum1+=@y_array[i]*Math.log(@x_array[i])            # 'sum1' is the sum of y times lnx    
    end
    sum2=@x_array.map{|ele| Math.log(ele)**2}.reduce(:+) # 'sum2' is the sum of lnx^2
    sum_y=@y_array.reduce(:+)                            # 'sum_y' is the sum of y
    sum_lnx=@x_array.map{|ele| Math.log(ele)}.reduce(:+) # 'sum_lnx' is the sum of lnx


    a=(n*sum1-sum_y*sum_lnx)/(n*sum2-sum_lnx**2)
    b=(sum_y-a*sum_lnx)/n

    co_log=[a.round(2),b.round(2)]

    return co_log

  end

  # Function 'put_log' prints the regression formula b*ln(x)+a.

  def put_log

      puts "#{co_log[0]}*ln(x) + #{co_log[1]}"

  end

  # Function 'var_log' calculates the variance(RSS) of logarithms regression.

  def var_log

    ye_array=@x_array.map{|ele| co_log[0]*Math.log(ele)+co_log[1]}  # Calculate the predicted values of y.
    var=0
    for i in (0..@y_array.length-1)
      var=var+(ye_array[i]-@y_array[i])**2
    end

    return var.round(*2)

  end

  # Function 'co_line' calculates the coefficients of linear regression y=a+bx. Here uses the gem 'LineFit'.

  def co_line

    lf=LineFit.new                 # Create the object 'lf' of gem 'LineFit'.
    lf.setData(@x_array,@y_array)  # Use the 'setData' method to input data x and y.
    a,b=lf.coefficients            # Use the 'coefficients' method to get the coefficients a,b
    co_line=[]
    co_line<<b.round(*2)
    co_line<<a.round(*2)

    return co_line

  end

  # Function 'put_log' prints the logarithms regression formula bx+a.

  def put_line
      puts "#{co_line[0]}x + #{co_line[1]}"
  end

  # Function 'var_line' calculates the variance(RSS) of linear regression.

  def var_line
    ye_array=@x_array.map{|ele| co_line[0]*ele+co_line[1]} # Calculate the predicted values of y.
    var=0
    for i in (0..@y_array.length-1)
      var=var+(ye_array[i]-@y_array[i])**2
    end

    return var.round(*2)

  end

  # Function 'co_exp' calculates the coefficients of exponential regression y=a*e^(bx).

  def co_exp

    sum_lny=@y_array.map{|ele| Math.log(ele)}.reduce(:+)   # 'sum_lny' is the sum of lny.
    sum_xlny=0
    for i in (0..@x_array.length-1)
      sum_xlny=sum_xlny+@x_array[i]*Math.log(@y_array[i])  # 'sum_xlny' is the sum of x times lny.
    end
    sum_xsq=@x_array.map{|ele|ele**2}.reduce(:+)           # 'sum_xsq' is the sum of x^2.
    sum_x=@x_array.reduce(:+)                              # 'sum_x' is the sum of x.
    n=@x_array.length
    a=(sum_lny*sum_xsq-sum_x*sum_xlny)/(n*sum_xsq-sum_x**2)
    b=(n*sum_xlny-sum_x*sum_lny)/(n*sum_xsq-sum_x**2)
    co_exp=[]
    co_exp<<Math.exp(a).round(2)
    co_exp<<b.round(2)
    return co_exp

  end

  # Function 'put_exp' prints the exponential regression formula a*e^x.

  def put_exp
    puts "#{co_exp[0]}*e^#{co_exp[1]}x"
  end

  # Function 'var_exp' calculates the variance(RSS) of exponential regression.

  def var_exp
    ye_array=@x_array.map{|ele|co_exp[0]*Math.exp(co_exp[1]*ele)}
    var=0
    for i in (0..@y_array.length-1)
      var+=(ye_array[i]-@y_array[i])**2
    end
    return var.round(2)
  end

  # Function 'put_final' takes in instance variable @type, the regression type from the command line
  # and then print corresponding formula.

  def put_final
    case @type
      when "linear"
        put_line
      when "polynomial"
        put_opt_poly
      when "exponential"
        begin            # In the printing of 'exponential' regression, it deals with the 'Math::DomainError'
          co_exp
          put_exp
        rescue Math::DomainError
          puts "Cannot perform exponential regression on this data"
        end
      when "logarithmic"
        begin            # In the printing of 'logarithmic' regression, it deals with the  'Math::DomainError'
          co_log
          put_log
        rescue Math::DomainError
          puts "Cannot perform logarithmic regression on this data"
        end
    end
  end

end


  test=Project1.new()
  test.file_to_array
  test.put_final














