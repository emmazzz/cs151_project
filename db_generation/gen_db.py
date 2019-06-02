import csv

num_movies = 1000

def format_name_list(name):
  names = name.split(' ')
  q_names = ["\"" + name.strip() + "\"" for name in names]
  return "["+','.join(q_names)+"]"

with open('movie_metadata.csv', 'rU') as infile:
  # read the file as a dictionary for each row ({header : value})
  reader = csv.DictReader(infile)
  data = {}
  count = 0
  for row in reader:
    if count > num_movies: break
    count += 1
    for header, value in row.items():
      try:
        data[header].append(value)
      except KeyError:
        data[header] = [value]

# extract the variables you want
director = data['director_name']
actor1 = data['actor_1_name']
actor2 = data['actor_2_name']
actor3 = data['actor_3_name']

title = data['movie_title']
print("database([")
for i in range(num_movies-1):
  print("  star("),
  print(format_name_list(title[i].strip()[:-2])+","),

  print("["+format_name_list(actor1[i])),
  if (actor2[i] != ""): print(","+format_name_list(actor2[i])), 
  if (actor3[i] != ""): print(","+format_name_list(actor3[i])), 
  print("],"),
  print(format_name_list(director[i])),
  
  print("), ")


i = num_movies-1
print("  star("),
print(format_name_list(title[i].strip()[:-2])+","),

print("["+format_name_list(actor1[i])),
if (actor2[i] != ""): print(","+format_name_list(actor2[i])), 
if (actor3[i] != ""): print(","+format_name_list(actor3[i])), 
print("],"),
print(format_name_list(director[i])),
  
print(")]).")





