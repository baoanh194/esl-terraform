terraform {
  required_version = ">= 0.15"
  # required_providers {
  #   random = {
  #     source  = "hashicorp/random"
  #     version = "~> 3.0"
  #   }
  # }
}

variable "words" {
  description = "A word pool to use for Mad Libs"
  type = object({
    nouns      = list(string),
    adjectives = list(string),
    verbs      = list(string),
    adverbs    = list(string),
    numbers    = list(number),
  })
}

# resource "random_shuffle" "random_nouns" {
#   input = var.words["nouns"]
# }

# resource "random_shuffle" "random_adjectives" {
#   input = var.words["adjectives"]
# }

# resource "random_shuffle" "random_verbs" {
#   input = var.words["verbs"]
# }

# resource "random_shuffle" "random_adverbs" {
#   input = var.words["adverbs"]
# }

# resource "random_shuffle" "random_numbers" {
#   input = var.words["numbers"]
# }

# # ### Outputing to CLI
# output "mad_libs" {
#   value = templatefile("bao.txt",
#     {
#       nouns      = random_shuffle.random_nouns.result
#       adjectives = random_shuffle.random_adjectives.result
#       verbs      = random_shuffle.random_verbs.result
#       adverbs    = random_shuffle.random_adverbs.result
#       numbers    = random_shuffle.random_numbers.result
#   })
# }

variable "num_files" {
  default = 100
  type    = number
}


##Looping by for to uppercase all string in var.words
locals {
  uppercase_words = {for k, v in var.words : k => [for s in v : upper(s)]}
}

### Shuffle word pool with count
resource "random_shuffle" "random_nouns" {
  count = 100
  input = local.uppercase_words["nouns"]
}

resource "random_shuffle" "random_adjectives" {
  count = 100
  input = local.uppercase_words["adjectives"]
}

resource "random_shuffle" "random_verbs" {
    count = 100
    input = local.uppercase_words["verbs"]
}

resource "random_shuffle" "random_adverbs" {
  count = 100
  input = local.uppercase_words["adverbs"]
}

resource "random_shuffle" "random_numbers" {
  count = 100
  input = local.uppercase_words["numbers"]
}

###Outputing to file
locals {
  templates = tolist(fileset(path.module, "*.txt"))
}

## Save the output to madlibs-<num>.txt file
resource "local_file" "mad_libs" {
  count    = 100
  filename = "madlibs/madlibs-${count.index}.txt"
  content = templatefile(element(local.templates, count.index),
    {
      nouns      = random_shuffle.random_nouns[count.index].result
      adjectives = random_shuffle.random_adjectives[count.index].result
      verbs      = random_shuffle.random_verbs[count.index].result
      adverbs    = random_shuffle.random_adverbs[count.index].result
      numbers    = random_shuffle.random_numbers[count.index].result
  })
}