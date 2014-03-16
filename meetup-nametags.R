#!/usr/bin/env Rscript

# meetup-nametags
# github.com/datacommunitydc/meetup-nametags

# usage: ./meetup-nametags MEETUP_API_KEY Meetup-URL-Name > tagslist.csv

options(stringsAsFactors=FALSE)

library(plyr)
library(httr)
library(rjson)

args <- commandArgs(trailingOnly = TRUE)

api_key <- args[[1]]
meetup_urlname <- args[[2]]
api = "https://api.meetup.com"

# get all upcoming events for this group
# (will be in ascending order, so we'll always extract the first one)
service = "2/events"
request.str = "%s/%s?key=%s&sign=true&group_urlname=%s&status=upcoming"
request <- sprintf(request.str, api, service, api_key, meetup_urlname)

events <- GET(request)
stop_for_status(events)

events_json <- content(events)
event_id <- events_json$results[[1]]$id
event_rsvps <- events_json$results[[1]]$yes_rsvp_count

# get all RSVPs
# foreach event, get all yes RSVPs
# need just the member id
page.size = 200 # not sure why this can't be higher...
getSomeRSVPs <- function(api, api.key, event.id, offset=0, page=page.size) {
    service = "2/rsvps"
    request.str = "%s/%s?key=%s&sign=true&rsvp=yes&event_id=%s&page=%d&offset=%d&only=member"
    request <- sprintf(request.str, api, service, api.key, event.id, page=page, offset=offset)
    rsvps_response <- GET(request)
    stop_for_status(rsvps_response)
    rsvps <- content(rsvps_response)
    member_ids <- unlist(llply(rsvps$results, function(r) r$member$member_id))
    member_ids
}
member_ids <- llply(seq.int(from=0,to=floor(event_rsvps/page.size)),
               function(o) getSomeRSVPs(api, api_key, event_id, offset=o, page=page.size))
member_ids <- unlist(member_ids)

# iterate over the profiles -- get 20 at a time
getSomeProfiles <- function(api, api.key, group_urlname, member_ids) {
    service = "2/profiles"
    request.str = "%s/%s?key=%s&sign=true&member_id=%s&group_urlname=%s&page=20&only=name,role,title"
    request <- sprintf(request.str, api, service, api.key, member_ids, group_urlname)
    profiles_response <- GET(request)
    stop_for_status(profiles_response)
    profiles <- content(profiles_response)
    ldply(profiles$results, function(r) data.frame(name=r$name, 
                                                   title=if ('title' %in% names(r)) r$title else '',
                                                   role=if ('role' %in% names(r)) r$role else ''))
}
member_ids_df <- data.frame(member_ids, group=floor(seq_along(member_ids)/20))
profiles <- ddply(member_ids_df, .(group), function(id_df) {
    id_str <- paste(id_df$member_ids, collapse=',')
    getSomeProfiles(api, api_key, meetup_urlname, id_str)
})
profiles$titlerole <- with(profiles, ifelse(role != '', role, title))

# filter to only profiles with a role
profiles <- subset(profiles, titlerole != '', select=c(-group))

# output a CSV
write.csv(profiles, row.names=FALSE)
