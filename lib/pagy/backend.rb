# See Pagy::Backend API documentation: https://ddnexus.github.io/pagy/api/backend

class Pagy
  # Defines a few generic methods to paginate an ORM collection out of the box,
  # or any collection by overriding pagy_get_items and/or pagy_get_vars in your controller

  # See also the extras if you need specialized methods to paginate Arrays or other collections

  module Backend ; private         # the whole module is private so no problem with including it in a controller

    # Return Pagy object and items
    def pagy(collection, vars={})
      pagy = Pagy.new(pagy_get_vars(collection, vars))
      return pagy, pagy_get_items(collection, pagy)
    end

    # Sub-method called only by #pagy: here for easy customization of variables by overriding
    def pagy_get_vars(collection, vars)
      count = collection.count(:all)                # work with AR collections: other ORMs may need to change this
      count = count.count if count.is_a?(Hash)      # fix for the AR grouping count inconsistency (Hash instead of Integer)
      # Return the merged variables to initialize the Pagy object
      { count: count, page: params[vars[:page_param]||VARS[:page_param]] }.merge!(vars)
    end

    # Sub-method called only by #pagy: here for easy customization of record-extraction by overriding
    def pagy_get_items(collection, pagy)
      # This should work with ActiveRecord, Sequel, Mongoid...
      collection.offset(pagy.offset).limit(pagy.items)
    end

    def pagy_grouped_by(grouped_by_hash_collection, vars={})
      pagy = PagyGroupedBy.new(pagy_get_grouped_by_vars(grouped_by_hash_collection, vars))
      raise NotImplementedError
      # please come back and ensure that the pagy_get_items method is properly called for group_by hashes
      return pagy, pagy_get_items(grouped_by_hash_collection, pagy)
    end

    # Sub-method called only by #pagy_grouped_by: here for easy customization of variables by overriding
    def pagy_get_grouped_by_vars(grouped_by_hash_collection, vars)
      grouped_by_hash =  Hash[grouped_by_hash.map{|k, v| [k, v.count] }]

      { grouped_by_hash: grouped_by_hash, page: params[vars[:page_param]||VARS[:page_param]] }.merge!(vars)
    end

  end
end
