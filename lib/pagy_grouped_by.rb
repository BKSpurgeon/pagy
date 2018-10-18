require 'pathname'

class PagyGroupedBy < Pagy

  def initialize(vars)
    @vars = remove_empty_keys(vars)
    validate_instance_variables

    @pages = @last = get_last                      # cardinal and ordinal meanings
    @page <= @last or raise(OutOfRangeError.new(self), "expected :page in 1..#{@last}; got #{@page.inspect}")
    @offset = @items * (@page - 1) + @outset                                   # pagination offset + outset (initial offset)
    @items  = @count - ((@pages-1) * @items) if @page == @last && @count > 0   # adjust items for last non-empty page
    @from   = @count == 0 ? 0 : @offset+1 - @outset                            # page begins from item
    @to     = @count == 0 ? 0 : @offset + @items - @outset                     # page ends to item
    @prev   = (@page-1 unless @page == 1)                                      # nil if no prev page
    @next   = (@page+1 unless @page == @last)                                  # nil if no next page
  end


  # Return the array of page numbers and :gap items e.g. [1, :gap, 7, 8, "9", 10, 11, :gap, 36]
  def series(size=@vars[:size])
    4.times{|i| (size[i]>=0 rescue nil) or raise(ArgumentError, "expected 4 items >= 0 in :size; got #{size.inspect}")}
    series = []
    [*0..size[0], *@page-size[1]..@page+size[2], *@last-size[3]+1..@last+1].sort!.each_cons(2) do |a, b|
      if    a<0 || a==b || a>@last                                        # skip out of range and duplicates
      elsif a+1 == b; series.push(a)                                      # no gap     -> no additions
      elsif a+2 == b; series.push(a, a+1)                                 # 1 page gap -> fill with missing page
      else            series.push(a, :gap)                                # n page gap -> add :gap
      end                                                                 # skip the end boundary (last+1)
    end                                                                   # shift the start boundary (0) and
    series.tap{|s| s.shift; s[s.index(@page)] = @page.to_s}               # convert the current page to String
  end

  private
  def remove_empty_keys(vars)
    VARS.merge(vars.delete_if{|_,v| v.nil? || v == '' })               # default vars + cleaned vars
  end

  def validate_instance_variables
    grouped_by_hash = @vars[:grouped_by_hash]
    unless grouped_by_hash.nil?
      @count = grouped_by_hash.keys.each{|k| h[k] = h[k].map(&:count).inject(:+)}
    end

    { count:0, items:1, outset:0, page:1 }.each do |k,min|                     # validate instance variables
      (@vars[k] && instance_variable_set(:"@#{k}", @vars[k].to_i) >= min) \
        or raise(ArgumentError, "expected :#{k} >= #{min}; got #{instance_variable_get(:"@#{k}").inspect}")
        end
  end

  def get_last
    [(@grouped_by_hash.values.last.to_f / @items).ceil, 1].max
  end
end
