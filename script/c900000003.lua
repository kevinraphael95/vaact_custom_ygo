--Magicienne des Ténèbres
function c900000003.initial_effect(c)
	-- Update ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c900000003.atkval)
	c:RegisterEffect(e1)
end

function c900000003.atkval(e,c)
	local g=Duel.GetMatchingGroup(Card.IsCode,c:GetControler(),LOCATION_GRAVE,LOCATION_GRAVE,nil,46986414) -- Dark Magician ID
	return g:GetCount()*500
end
