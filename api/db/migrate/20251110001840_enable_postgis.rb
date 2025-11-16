class EnablePostgis < ActiveRecord::Migration[8.1]
  def change
    enable_extension 'postgis'
    enable_extension 'btree_gin'   # useful, optional
    enable_extension 'pg_trgm'     # optional for fuzzy search
  end
end
