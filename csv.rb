require 'csv'
require 'awesome_print'

class CSVImport
  attr_reader :config

  def initialize
    @config = CSVImportConfiguration.new
  end

  def self.from_file(path)
    import = new
    yield import.config
    rows = CSV.read(path, col_sep: ";")
    import.process rows
  end

  def process(rows)
    rows.map { |row| process_row(row) }
  end

  def process_row(row)
    data = {}
    @config.columns.each do |col|
      data[col.name] = col.type.call(row[col.col_number])
    end
    return data
  end
end

class CSVImportConfiguration
  attr_reader :columns
  Column = Struct.new(:name, :col_number, :type)
  
  def initialize
    @columns = []
  end
  def string(first_name, column:)
    @columns << Column.new(first_name, column - 1, -> (x) { x.to_s })
  end
  def integer(age, column:)
    @columns << Column.new(age, column - 1, -> (x) { x.to_i })
  end
  def decimal(salary, column:)
    @columns << Column.new(salary, column - 1, -> (x) { x.to_f })
  end
end

records = CSVImport.from_file("data.csv") do |config|
  config.string :first_name, column: 1
  config.string :last_name, column: 2
  config.integer :age, column: 4
  config.decimal :salary, column: 5
end

ap records