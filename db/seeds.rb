# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
Framework.create([
  {
    name:        'Spark',
    description: '...',
    port:        ':8080'
  },
  {
    name:        'Hadoop',
    description: '...',
    port:        ':8088'
  },
  {
    name:        'HDFS',
    description: '...',
    port:        ':50070'
  },
  {
    name:        'Zeppelin',
    description: '...',
    port:        ':8070'
  },
  {
    name:        'Jupyter',
    description: '...',
    port:        ':8888'
  }
])
