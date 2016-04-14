------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.0")("Firemaw")
local L = AceLibrary("AceLocale-2.0"):new("BigWigs"..boss)

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Firemaw",

	wingbuffet_cmd = "wingbuffet",
	wingbuffet_name = "Wing Buffet alert",
	wingbuffet_desc = "Warn for Wing Buffet",
    wingbuffet_trigger = "Firemaw begins to cast Wing Buffet",
	wingbuffet_message = "Wing Buffet! 30sec to next!",
	wingbuffet_warning = "3sec to Wing Buffet!",
	wingbuffet_bar = "Wing Buffet",
          
    shadowflame_cmd = "shadowflame",
	shadowflame_name = "Shadow Flame alert",
	shadowflame_desc = "Warn for Shadow Flame",
    shadowflame_trigger = "Firemaw begins to cast Shadow Flame.",
    shadowflame_warning = "Shadow Flame Incoming!",
    shadowflame_bar = "Possible Shadow Flame",
} end)

L:RegisterTranslations("zhCN", function() return {
	wingbuffet_trigger = "费尔默开始施放龙翼打击。",
	shadowflame_trigger = "费尔默开始施放暗影烈焰。",

	wingbuffet_warning = "3秒后发动龙翼打击！",
	shadowflame_warning = "暗影烈焰发动！",

	wingbuffet_bar = "龙翼打击",

	wingbuffet_name = "龙翼打击警报",
	wingbuffet_desc = "龙翼打击警报",

	shadowflame_name = "暗影烈焰警报",
	shadowflame_desc = "暗影烈焰警报",
} end)


L:RegisterTranslations("koKR", function() return {
	wingbuffet_trigger = "화염아귀|1이;가; 폭풍 날개|1을;를; 시전합니다.",
	shadowflame_trigger = "화염아귀|1이;가; 암흑의 불길|1을;를; 시전합니다.",

	wingbuffet_message = "폭풍 날개! 다음은 30초 후!",
	wingbuffet_warning = "3초 후 폭풍 날개!",
	shadowflame_warning = "암흑 불길 경고!",

	wingbuffet_bar = "폭풍 날개",
	
	wingbuffet_name = "폭풍 날개 경고",
	wingbuffet_desc = "폭풍 날개에 대한 경고",
	
	shadowflame_name = "암흑의 불길 경고",
	shadowflame_desc = "암흑의 불길에 대한 경고",
} end)

L:RegisterTranslations("deDE", function() return {
	wingbuffet_trigger = "Feuerschwinge beginnt Fl\195\188gelsto\195\159 zu wirken.",
	shadowflame_trigger = "Feuerschwinge beginnt Schattenflamme zu wirken.",

	wingbuffet_message = "Fl\195\188gelsto\195\159! N\195\164chster in 30 Sekunden!",
	wingbuffet_warning = "Fl\195\188gelsto\195\159 in 3 Sekunden!",
	shadowflame_warning = "Schattenflamme!",

	wingbuffet_bar = "Fl\195\188gelsto\195\159",

	wingbuffet_name = "Fl\195\188gelsto\195\159",
	wingbuffet_desc = "Warnung, wenn Feuerschwinge Fl\195\188gelsto\195\159 wirkt.",

	shadowflame_name = "Schattenflamme",
	shadowflame_desc = "Warnung, wenn Feuerschwinge Schattenflamme wirkt.",
    shadowflame_bar = "M\195\182gliche Schattenflamme",
} end)

L:RegisterTranslations("frFR", function() return {
	wingbuffet_trigger = "Gueule%-de%-feu commence \195\160 lancer Frappe des ailes.",
	shadowflame_trigger = "Gueule-de-feu commence \195\160 lancer Flamme d'ombre.",

	wingbuffet_warning = "3 sec avant prochain Frappe des ailes!",
	shadowflame_warning = "Flamme d'ombre imminente!",
} end)


----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsFiremaw = BigWigs:NewModule(boss)
BigWigsFiremaw.zonename = AceLibrary("Babble-Zone-2.0")("Blackwing Lair")
BigWigsFiremaw.enabletrigger = boss
BigWigsFiremaw.toggleoptions = {"wingbuffet", "shadowflame", "bosskill"}
BigWigsFiremaw.revision = tonumber(string.sub("$Revision: 13478 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsFiremaw:OnEnable()
    started = nil
    
    self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")

	self:RegisterEvent("BigWigs_RecvSync")
	self:TriggerEvent("BigWigs_ThrottleSync", "FiremawWingBuffet2", 10)
	self:TriggerEvent("BigWigs_ThrottleSync", "FiremawShadowflame", 10)
end

------------------------------
--      Event Handlers      --
------------------------------

function BigWigsFiremaw:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE(msg)
	if string.find(msg, L["wingbuffet_trigger"]) then
		self:TriggerEvent("BigWigs_SendSync", "FiremawWingBuffet3")
	elseif msg == L["shadowflame_trigger"] then 
		self:TriggerEvent("BigWigs_SendSync", "FiremawShadowflame")
	end
end

function BigWigsFiremaw:BigWigs_RecvSync(sync, rest)
	if sync == self:GetEngageSync() and rest and rest == boss and not started then
		started = true
		if self:IsEventRegistered("PLAYER_REGEN_DISABLED") then self:UnregisterEvent("PLAYER_REGEN_DISABLED") end
		
        self:TriggerEvent("BigWigs_StartBar", self, L["wingbuffet_bar"], 25, "Interface\\Icons\\Spell_Fire_SelfDestruct")
        
        self:ScheduleEvent("countdown3", "BigWigs_Message", 22, "", "Urgent", true, "Three")
        self:ScheduleEvent("countdown2", "BigWigs_Message", 23, "", "Urgent", true, "Two")
        self:ScheduleEvent("countdown1", "BigWigs_Message", 24, "", "Urgent", true, "One")  
    end
    
    if sync == "FiremawWingBuffet3" and self.db.profile.wingbuffet then
		self:TriggerEvent("BigWigs_Message", L["wingbuffet_message"], "Important")
		self:TriggerEvent("BigWigs_StartBar", self, L["wingbuffet_bar"], 30, "Interface\\Icons\\Spell_Fire_SelfDestruct")
        
        self:ScheduleEvent("countdown3", "BigWigs_Message", 27, "", "Urgent", true, "Three")
        self:ScheduleEvent("countdown2", "BigWigs_Message", 28, "", "Urgent", true, "Two")
        self:ScheduleEvent("countdown1", "BigWigs_Message", 29, "", "Urgent", true, "One") 
	elseif sync == "FiremawShadowflame" and self.db.profile.shadowflame then
		self:TriggerEvent("BigWigs_Message", L["shadowflame_warning"], "Important", true, "Alarm")
        self:TriggerEvent("BigWigs_StartBar", self, L["shadowflame_bar"], 16, "Interface\\Icons\\Spell_Fire_Fire")
	end
end

