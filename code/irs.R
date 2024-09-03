library("here")
library("data.table")

# load
load(here("data/irs/lottery.RData"))
irs = data.table(d); rm(d)

# create variables
irs[, winner_small := as.numeric(winner == 1 & bigwinner == 0)]
irs[, education_college := as.numeric(educ >= 16)]

# drop
irs = irs[, .SD, .SDcols = !patterns("np\\.\\d$|yearlpr")]

# rename
colnames(irs) = gsub("xearn\\.(\\d)$", "earnings_pre_\\1", colnames(irs))
colnames(irs) = gsub("yearn\\.(\\d)$", "earnings_post_\\1", colnames(irs))
dict = c(
    "male" = "man",
    "bigwinner" = "winner_big",
    "workthen" = "work",
    "tixbot" = "tickets",
    "yearw" = "year",
    "agew" = "age",
    "educ" = "education"
)
setnames(irs, old = names(dict), new = dict)

# earnings averages
irs[, earnings_pre_avg := rowMeans(.SD), .SDcols = patterns("earnings_pre")]
irs[, earnings_post_avg := rowMeans(.SD), .SDcols = patterns("earnings_post")]

# reorder columns
a = irs[, .SD, .SDcols = !patterns("earnings")]
b = irs[, .SD, .SDcols = patterns("earnings")]
irs = cbind(
    a[, sort(names(a)), with = FALSE], 
    b[, sort(names(b)), with = FALSE]
)

# write to file
fwrite(irs, here("data/irs/irs.csv"))
