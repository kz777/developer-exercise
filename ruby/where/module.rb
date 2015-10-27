class Array
	def where(h_of_a = {})
		raise ArgumentError, 'no more than two criterias at a time' if h_of_a.values.length > 2
    	self.select { |par| h_of_a.values[0] === par[h_of_a.keys[0]] && h_of_a.values[1] === par[h_of_a.keys[1]] }
    end
end
