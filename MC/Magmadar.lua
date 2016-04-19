------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.0")("Magmadar")
local L = AceLibrary("AceLocale-2.0"):new("BigWigs"..boss)

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	-- Chat message triggers
	--trigger1 = "%s goes into a killing frenzy!",
    trigger1 = "Magmadar is afflicted by Frenzy.",
	trigger2 = "afflicted by Panic",
    trigger2b = "Magmadar 's Panic",

	-- Warnings and bar texts
	["Frenzy alert!"] = true,
	["5 seconds until AoE Fear!"] = true,
	["AoE Fear - 30 seconds until next!"] = true,
	["AoE Fear"] = true,

	-- AceConsole strings
	cmd = "Magmadar",
	
	fear_cmd = "fear",
	fear_name = "Warn for Fear",
	fear_desc = "Warn when Magmadar casts AoE Fear",
	
	frenzy_cmd = "frenzy",
	frenzy_name = "Frenzy alert",
	frenzy_desc = "Warn when Magmadar goes into a frenzy",
    frenzy_bar = "Frenzy",
} end)

L:RegisterTranslations("koKR", function() return {
	-- Chat message triggers
	trigger1 = "%s|1이;가; 살기를 띤 듯한 광란의 상태에 빠집니다!",
	trigger2 = "공황에 걸렸습니다.",

	-- Warnings and bar texts
	["Frenzy alert!"] = "광폭화 경보 - 사냥꾼의 평정 사격을 쏘세요!",
	["5 seconds until AoE Fear!"] = "5초후 광역 공포!",
	["AoE Fear - 30 seconds until next!"] = "광역 공포 경보 - 다음 공포까지 30초!",
	["AoE Fear"] = "광역 공포",

	fear_name = "공포 경고",
	fear_desc = "마그마다르 공포 시전 시 경고",
	
	frenzy_name = "광폭화 경고",
	frenzy_desc = "마그마다르 광폭화 시 경고",
} end)


L:RegisterTranslations("zhCN", function() return {
	trigger1 = "变得狂怒无比！",
	trigger2 = "受到了恐慌",

	["Frenzy alert!"] = "狂暴警报 - 猎人立刻使用宁神射击！",
	["5 seconds until AoE Fear!"] = "5秒后发动群体恐惧！",
	["AoE Fear - 30 seconds until next!"] = "群体恐惧 - 30秒后再次发动",
	["AoE Fear"] = "群体恐惧",
	
	fear_name = "恐惧警报",
	fear_desc = "恐惧警报",
	
	frenzy_name = "狂暴警报",
	frenzy_desc = "狂暴警报",
} end)


L:RegisterTranslations("deDE", function() return {
	trigger1 = "%s ger\195\164t in t\195\182dliche Raserei!",
	trigger2 = "von Panik betroffen",

	["Frenzy alert!"] = "Raserei! - Einlullender Schuss!",
	["5 seconds until AoE Fear!"] = "AoE Furcht in 5 Sekunden!",
	["AoE Fear - 30 seconds until next!"] = "AoE Furcht! N\195\164chste in 30 Sekunden!",
	["AoE Fear"] = "AoE Furcht",

	fear_name = "Furcht",
	fear_desc = "Warnung, wenn Magmadar AoE Furcht wirkt.",
	
	frenzy_name = "Raserei",
	frenzy_desc = "Warnung, wenn Magmadar in Raserei ger\195\164t.",
} end)

L:RegisterTranslations("frFR", function() return {
	trigger1 = "%s entre dans une fr\195\169n\195\169sie sanglante !",
	trigger2 = "Panique.",

	["Frenzy alert!"] = "Alerte fr\195\169n\195\169sie - Tir tranquilisant !",
	["5 seconds until AoE Fear!"] = "AoE Fear dans 5 secondes !",

	["AoE Fear - 30 seconds until next!"] = "AoE Fear - 30 sec avant le prochain !",
	["AoE Fear"] = "AoE Fear",

	fear_name = "fear",
	fear_desc = "Pr\195\169venir quand Magmadar lance AoE Fear.",

	frenzy_name = "Fr\195\169n\195\169sie",
	frenzy_desc = "Pr\195\169venir quand Magmadar passe en fr\195\169n\195\169sie.",
} end)

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsMagmadar = BigWigs:NewModule(boss)
BigWigsMagmadar.zonename = AceLibrary("Babble-Zone-2.0")("Molten Core")
BigWigsMagmadar.enabletrigger = boss
BigWigsMagmadar.toggleoptions = {"fear", "frenzy", "bosskill"}
BigWigsMagmadar.revision = tonumber(string.sub("$Revision: 13478 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsMagmadar:OnEnable()
	self.prior = nil
    started = nil
    
	--self:RegisterEvent("BigWigs_Message")
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE", "Frenzy")
    self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Frenzy")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Frenzy")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Fear")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Fear")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Fear")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")
    self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")

	self:RegisterEvent("BigWigs_RecvSync")
	self:TriggerEvent("BigWigs_ThrottleSync", "MagmadarFear", 5)
end

------------------------------
--      Event Handlers      --
------------------------------

--[[function BigWigsMagmadar:CHAT_MSG_MONSTER_EMOTE(msg)
	if msg == L["trigger1"] and self.db.profile.frenzy then
		self:TriggerEvent("BigWigs_Message", L["Frenzy alert!"], "Important", nil, "Alert")
	end
end]]
function BigWigsMagmadar:Frenzy(msg)
	if self.db.profile.frenzy then
        if string.find(msg, L["trigger1"]) then
            self:TriggerEvent("BigWigs_Message", L["Frenzy alert!"], "Important", nil, "Alert")
            self:TriggerEvent("BigWigs_StartBar", self, L["frenzy_bar"], 15, "Interface\\Icons\\ability_druid_challangingroar")
        end
    end
end

function BigWigsMagmadar:BigWigs_RecvSync(sync, rest) 
	if sync == self:GetEngageSync() and rest and rest == boss and not started then
		started = true
		if self:IsEventRegistered("PLAYER_REGEN_DISABLED") then self:UnregisterEvent("PLAYER_REGEN_DISABLED") end

        --self:TriggerEvent("BigWigs_Message", L["engage_msg"], "Attention")
        self:TriggerEvent("BigWigs_StartBar", self, L["AoE Fear"], 20, "Interface\\Icons\\Spell_Shadow_PsychicScream")
		self:ScheduleEvent("BigWigs_Message", 15, L["5 seconds until AoE Fear!"], "Urgent")
        
        self:TriggerEvent("BigWigs_StartBar", self, L["frenzy_bar"], 20, "Interface\\Icons\\ability_druid_challangingroar")
    end
    if sync ~= "MagmadarFear" then return end
	if self.db.profile.fear then
		self:TriggerEvent("BigWigs_StartBar", self, L["AoE Fear"], 30, "Interface\\Icons\\Spell_Shadow_PsychicScream")
		self:TriggerEvent("BigWigs_Message", L["AoE Fear - 30 seconds until next!"], "Important")
		self:ScheduleEvent("BigWigs_Message", 25, L["5 seconds until AoE Fear!"], "Urgent")
	end
end

function BigWigsMagmadar:Fear(msg)
	if not self.prior and string.find(msg, L["trigger2"]) then
		self:TriggerEvent("BigWigs_SendSync", "MagmadarFear")
		self.prior = true
	end
end

--[[function BigWigsMagmadar:BigWigs_Message(text)
	if text == L["5 seconds until AoE Fear!"] then self.prior = nil end
end]]
