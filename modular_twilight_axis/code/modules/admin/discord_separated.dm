/proc/send2discordwh(var/data)
    world.Export("http://127.0.0.1:8080", data, 0, null, "POST")

/proc/roundend_notify_discord()
    var/list/data = list(
        "type"= "roundend"
    )
    send2discordwh(data)    

/datum/admin_help/New(msg, client/C, is_bwoink)
    . = ..()
    var/list/data = list(
        "type"= "ahelp",
        "id"= "[id]",
        "round_id"= GLOB.rogue_round_id,
        "opened_at"= "[opened_at]",
        "initiator"= "[initiator]",
        "adminstarted"= "[is_bwoink]",
        "message"= msg
    )
    send2discordwh(data)

/datum/admin_help/Close(key_name, silent)
    . = ..()
    var/list/data = list(
        "type"= "close",
        "id"= "[id]",
        "initiator"= "[key_name]",
    )
    send2discordwh(data)    

/datum/admin_help/Reopen(key_name)
    . = ..()
    var/list/data = list(
        "type"= "reopen",
        "id"= "[id]",
        "initiator"= "[key_name]",
    )
    send2discordwh(data)    


/datum/admin_help/mentorissue(key_name)
    . = ..()
    var/list/data = list(
        "type"= "mentorissue",
        "id"= "[id]",
        "initiator"= "[key_name]",
    )
    send2discordwh(data)    


/datum/admin_help/Resolve(key_name, silent)
    . = ..()
    var/list/data = list(
        "type"= "resolve",
        "id"= "[id]",
        "initiator"= "[key_name]",
    )
    send2discordwh(data)    

    
/datum/admin_help/Reject(key_name)
    . = ..()
    var/list/data = list(
        "type"= "reject",
        "id"= "[id]",
        "initiator"= "[key_name]",
    )
    send2discordwh(data)    


/datum/admin_help/ICIssue(key_name)
    . = ..()
    var/list/data = list(
        "type"= "icissue",
        "id"= "[id]",
        "initiator"= "[key_name]",
    )
    send2discordwh(data)    

    
/datum/admin_help/handle_issue(key_name)
    . = ..()
    var/list/data = list(
        "type"= "handle",
        "id"= "[id]",
        "initiator"= "[key_name]",
    )
    send2discordwh(data)

/datum/admin_help_tickets/ClientLogin(client/C)
    . = ..()
    if(C.current_ticket)
        var/list/data = list(
            "type"= "login",
            "id"= "[C.current_ticket.id]",
            "initiator"= "[C.ckey]",
        )
        send2discordwh(data)

/datum/admin_help_tickets/ClientLogout(client/C)
    . = ..()
    if(C.current_ticket)
        var/list/data = list(
            "type"= "logout",
            "id"= "[C.current_ticket.id]",
            "initiator"= "[C.ckey]",
        )
        send2discordwh(data)

/datum/world_topic/reopen_ticket
	keyword = "reopen"
	require_comms_key = TRUE

/datum/world_topic/reopen_ticket/Run(list/input)
    var/datum/admin_help/ticket = GLOB.ahelp_tickets.TicketByID(text2num(input["id"]))
    var/sender = input["initiator"]    
    if(!ticket)
        return

    var/irc_tagged = "[sender]"
    ticket.Reopen(irc_tagged)

/datum/world_topic/close_ticket
	keyword = "close"
	require_comms_key = TRUE

/datum/world_topic/close_ticket/Run(list/input)
    var/datum/admin_help/ticket = GLOB.ahelp_tickets.TicketByID(text2num(input["id"]))
    var/sender = input["initiator"]
    if(!ticket)
        return

    var/irc_tagged = "[sender]"
    ticket.Close(irc_tagged)

/datum/world_topic/reject_ticket
	keyword = "reject"
	require_comms_key = TRUE

/datum/world_topic/reject_ticket/Run(list/input)
    var/datum/admin_help/ticket = GLOB.ahelp_tickets.TicketByID(text2num(input["id"]))
    var/sender = input["initiator"]
    if(!ticket)
        return

    var/irc_tagged = "[sender]"
    ticket.Reject(irc_tagged)


/datum/world_topic/icissue_ticket
	keyword = "icissue"
	require_comms_key = TRUE

/datum/world_topic/icissue_ticket/Run(list/input)
    var/datum/admin_help/ticket = GLOB.ahelp_tickets.TicketByID(text2num(input["id"]))
    var/sender = input["initiator"]
    if(!ticket)
        return

    var/irc_tagged = "[sender]"
    ticket.ICIssue(irc_tagged)

/datum/world_topic/mentorissue_ticket
	keyword = "mentorissue"
	require_comms_key = TRUE

/datum/world_topic/mentorissue_ticket/Run(list/input)
    var/datum/admin_help/ticket = GLOB.ahelp_tickets.TicketByID(text2num(input["id"]))
    var/sender = input["initiator"]
    if(!ticket)
        return

    var/irc_tagged = "[sender]"
    ticket.mentorissue(irc_tagged)

/datum/world_topic/resolve_ticket
	keyword = "resolve"
	require_comms_key = TRUE

/datum/world_topic/resolve_ticket/Run(list/input)
    var/datum/admin_help/ticket = GLOB.ahelp_tickets.TicketByID(text2num(input["id"]))
    var/sender = input["initiator"]
    if(!ticket)
        return

    var/irc_tagged = "[sender]"
    ticket.Resolve(irc_tagged)

/datum/world_topic/handle_ticket
	keyword = "handle"
	require_comms_key = TRUE

/datum/world_topic/handle_ticket/Run(list/input)
    var/datum/admin_help/ticket = GLOB.ahelp_tickets.TicketByID(text2num(input["id"]))
    var/sender = input["initiator"]
    if(!ticket)
        return

    var/irc_tagged = "[sender]"
    ticket.handle_issue(irc_tagged)

