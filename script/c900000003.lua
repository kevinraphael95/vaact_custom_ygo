-- Magicienne des Ténèbres
local s,id=GetID()
function s.initial_effect(c)
	-------------------------------------
	-- Gagne 500 ATK pour chaque "Magicien Sombre" dans les Cimetières
	-------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
end

-------------------------------------
-- Calcul de l'ATK bonus
-------------------------------------
function s.atkval(e,c)
	local g=Duel.GetMatchingGroup(Card.IsCode,c:GetControler(),LOCATION_GRAVE,LOCATION_GRAVE,nil,46986414)
	return g:GetCount()*500
end
