# '<OFCS CAN BE CURRENCY SYSTEM.',
# find-or-create module OFCS
# ? currency system

# 'UNITS CAN BE CONSTITUTED_OF_OR_FILLED_WITH VALUE.',
# find-or-create module Unit
# ? value

# 'UNITS CAN BE ANONYMOUS.',
# find-or-create module Unit
# make inherited module Unit/Anonymous
# or make attribute IsAnonymous
# or ? create attribute for Unit called Types and add "Anonymous"

# 'A VALUE CAN BE SYMBOLIC.',
# find-or-create module Value
# make inherited module Value/Symbolic
# or make attribute IsSymbolic
# ? create attribute for Value called Types and add "Symbolic"

# 'DEBITS MAY BE APPLY -ED.',
# find-or-create module Debit
# create function in Debit called Apply

# 'ACCOUNTS CAN BE CONSTITUTED_OF_OR_FILLED_WITH INDIVIDUALS.',
# find-or-create module Account
# find-or-create module Individual
# create collection called Individuals in Account having type Individual
# create function in Account called Fill with an argument of an array having type Individual, which adds to the collection Individuals

# 'CREDITS MAY BE TRANSFER -ED FROM AN ACCOUNT.',
# find-or-create module Account
# find-or-create module Credit
# # this isn't quite right, is it? create function in Account called Transfer with an argument of an array having type Credit

# 'CASH CAN BE IN A SYSTEM.',
# either figure out if system refers to something else, or
# find-or-create module System
# create attribute of System called Cash

# 'CREDIT CAN BE A RECORD OF AN EVENT.',
# find-or-create module Credit
# find-or-create module Record
# find-or-create module Event
# assert Credit isa Record
# make inherited module Record/Event
# ? create attribute for Record called Types and add "Event"
# ?

# 'CASH MAY BE REPLACE -ED BY DOCUMENTATION.',
# find-or-create module Cash
# find-or-create module Documentation
# ? create function in Cash called Replace with an argument of type Documentation
# ? create function in Documentation called Replace with an argument of type Cash

# 'A REPRESENTATION MAY BE NEED -ED.',
# find-or-create module Representation
# create attribute of Representation called Need (ed?)

# 'A REPRESENTATION CAN BE PHYSICAL.',
# find-or-create module Representation
# create attribute of Representation called Physical

# 'AN ACCOUNT MAY BE OPEN -ED UNDER A NAME.',
# find-or-create module Account
# find-or-create module Name
# create function in Account called OpenedUnder with an argument of type Name

# 'AN OFCS[PERSON??] MAY HAVE AN ACCOUNT.',
# find-or-create module OFCS
# find-or-create module Account
# create attribute of OFCS called Account

# 'BIOMETRICS MAY ENSURE IDENTITY SECURITY.',
# find-or-create module Biometrics
# create function in Biometrics called EnsureIdentitySecurity
# create attribute in Biometrics called IdentitySecurityEnsured

# 'KEYS CAN BE PHYSICAL.'
# find-or-create module Key
# make inherited module Key/Physical
# ? create attribute for Value called Types and add "Symbolic"

# 'SOME_NUMBER_OF RECORDS MAY BE AUDIT -ED.',
# find-or-create module Record
# figure out where there are collections of type Record and add a function called Audit with an argument of an array of type Record

# 'INFORMATION MAY BE KEEP -ED SECRET.',
# find-or-create module Information
# ?????

# 'AN INFORMATION CAN BE PERSONAL.',

# 'INDIVIDUALS MAY CREATE AS SOME_NUMBER_OF ACCOUNTS.',
# 'INDIVIDUAL -S MAY WISH IN A SYSTEM.',
# 'SOME_NUMBER_OF DEBITS MAY BE AUDIT -ED.',
# 'SOME_NUMBER_OF DEBITS MAY BE CREATE -ED.',
# 'A FILE SYSTEM MAY ENSURE A PROPOSITION.',
# 'A FILE SYSTEM CAN BE REDUNDANT.',
# 'OFCS MAY SURVIVE A LOSS OF SOME_NUMBER_OF NODES.',
# 'NODES MAY UNDERGO A LOSS.',
# 'AN ATTACK CAN BE MALICIOUS.',
# 'CREDIT MAY HAVE A RECORD OF EVIDENCE.',
# 'A RECORD CAN BE CONSTITUTED_OF_OR_FILLED_WITH EVIDENCE.',
# 'VIDEO MAY BE BUILD -ED INTO A THING-REFERRED-TO.',
# 'A PARTY MAY VERIFY CREDIT.',
# 'SOME_NUMBER_OF DATA CAN BE ENCRYPTED.',
# 'OFCS MAY BE UTILIZE -ED FOR VARIETY OF PURPOSES.',
# 'OFCS CAN BE UNDERLYING.',
# 'VARIETY CAN BE CONSTITUTED_OF_OR_FILLED_WITH PURPOSES.',
# 'EXCHANGE SYSTEMS MAY BE CREATE -ED.',
# 'EXCHANGE SYSTEMS CAN BE MULTIPLE.',
# 'EXCHANGE SYSTEMS CAN BE INDEPENDENT.',
# 'A SYNDICATE MAY DECIDE.',
# 'A THING-REFERRED-TO MAY GOVERN A THING-REFERRED-TO.',
# 'A DEMOCRACY CAN BE DIRECT.',
# 'INDIVIDUALS CAN BE DESIGNATED.',
# 'A PURPOSE OF A SYNDICATE CAN BE CLEAR.',
# 'A SYNDICATE MAY HAVE A PURPOSE.',


###  'A <SINGULAR>.' => sub {
###    # check the result to see if it is indeed singular
###    return Match
###      (Input =>l
###  },
###  'A <SINGULAR> OF AN <SINGULAR>.' => sub {},
###  '<ATTRIBUTE>.' => 1,
###  # 'AVAILABLE TO SOME_NUMBER_OF MEMBERS OF A SYNDICATE.' => 1,
###  '<PAST-TENSE-VERB> INTO A THING-REFERRED-TO.' => 1,
###  'CONSTITUTED_OF_OR_FILLED_WITH <SINGULAR>.' => 1,
###  'CONSTITUTED_OF_OR_FILLED_WITH <PLURAL>.' => 1,
###  '<COMPOUND SINGULAR>.' => 1,
###  '<PAST-TENSE-VERB> BY SOME_NUMBER_OF <SINGULAR>.' => 1,
###  # 'FOR DISTRIBUTION OF <PLURAL>.' => 1,
###  'FOR <PLURAL>.' => 1,
###  '<STATE>.' => 1,
###  'IN A <SINGULAR>.' => 1,
###  'IN SOME_NUMBER_OF <PLURAL>.' => 1,
###  '<PAST-TENSE-VERB> <STATE>.' => 1,
###  '<PAST-TENSE-VERB> TO A <COMPOUND SINGULAR>.' => 1,
###  '<PAST-TENSE-VERB> UNDER A <SINGULAR>.' => 1,
###  '<PAST-TENSE-VERB> IN AN UNIT SYSTEM.' => 1,
###  '<PAST-TENSE-VERB> BY <SINGULAR>.' => 1,
###  '<PAST-TENSE-VERB> TO A <SINGULAR>.' => 1,
###  '<PAST-TENSE-VERB> FROM AN <SINGULAR>.' => 1,
###  '<PAST-TENSE-VERB> FOR VARIETY OF <PLURAL>.' => 1,
###  '<STATE> BY A <SINGULAR> OF A <SINGULAR>.' => 1,
