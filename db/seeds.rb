# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
password = (0...10).map { (33 + rand(93)).chr }.join

User.create(email: ENV["admin_email"],
            role:  "Admin",
            password:              password,
            password_confirmation: password)

open('admincredentials.log', 'w') { |f|
  f.puts "username: "+ENV["admin_email"]+"\npassword: "+password
}

Framework.create([
  {
    name:        'Spark',
    description: "Spark is an open source cluster computing framework. Originally developed at the University of California, Berkeley's AMPLab, the Spark codebase was later donated to the Apache Software Foundation, which has maintained it since. Spark provides an interface for programming entire clusters with implicit data parallelism and fault-tolerance.",
    port:        ':8080'
  },
  {
    name:        'Hadoop',
    description: "Hadoop is an open-source software framework used for distributed storage and processing of very large data sets. It consists of computer clusters built from commodity hardware. All the modules in Hadoop are designed with a fundamental assumption that hardware failures are a common occurrence and should be automatically handled by the framework.",
    port:        ':8088'
  },
  # {
  #   name:        'HDFS',
  #   description: "Hadoop Distributed File System (HDFS) – a distributed file-system that stores data on commodity machines, providing very high aggregate bandwidth across the cluster.",
  #   port:        ':50070'
  # },
  {
    name:        'Zeppelin',
    description: "Apache Zeppelin is a new and upcoming web-based notebook which brings data exploration, visualization, sharing and collaboration features to Spark. It support Python, but also a growing list of programming languages such as Scala, Hive, SparkSQL, shell and markdown.",
    port:        ':8070'
  },
  {
    name:        'Jupyter',
    description: "The Jupyter notebook extends the console-based approach to interactive computing in a qualitatively new direction, providing a web-based application suitable for capturing the whole computation process: developing, documenting, and executing code, as well as communicating the results.",
    port:        ':8888'
  }
])

user = User.create(email: "professor@zhaw.ch",
                   role:  "Professor",
                   password:              "password",
                   password_confirmation: "password")

group = Group.create(name: 'CAS Machine Intelligence: group 1',
                     desc: "The CAS Machine Intelligence course will answer to the following questions:\n How to create optimal conditions for machine learning?\n What is Deep Learning and where can it be used?\n How can textual analysis methods determine whether someone is positive or negative about a specific topic on social networks?\n What are the big data methods and how are they used?")

group.assignments.create(user: user)

User.create!(email: "professor1@zhaw.ch",
             role:  "Professor",
             password:              "password",
             password_confirmation: "password")


User.create!(email: "example@zhaw.ch",
             role:  "Student",
             password:              "password",
             password_confirmation: "password")

25.times do |n|
  email = "example-#{n+1}@zhaw.ch"
  password = "password"
  user = User.create(email: email,
                     role: "Student",
                     password:              password,
                     password_confirmation: password)
  group.assignments.create(user: user)
end
