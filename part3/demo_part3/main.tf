terraform {
  required_version = ">= 0.15"
    required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
  }
  }

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



# output "mablib_story" {
#   value = templatefile("bao.txt", {
#                                 nouns = random_shuffle.random_nouns.result
#                                 adjectives = random_shuffle.random_adjectives.result
#                                 verbs = random_shuffle.random_adverbs.result
#                                 adverbs = random_shuffle.random_adverbs.result
#                                 numbers = random_shuffle.random_numbers.result
#   })
#   }

locals{
  uppercase_words = {for key, val in var.words: key => [for str in val: upper(str)]}
}

locals {
  templates = tolist(fileset(path.module, ".txt"))
}

resource "local_file" "mablib_stories" {
  count = 100
  filename = "main/mablib-${count.index}.txt"
  content = templatefile(element(local.templates, count.index),
  {
    nouns = random_shuffle.random_nouns[count.index].result
    adjectives = random_shuffle.random_adjectives[count.index].result
    verbs = random_shuffle.random_adverbs[count.index].result
    adverbs = random_shuffle.random_adverbs[count.index].result
    numbers = random_shuffle.random_numbers[count.index].result
  })
}