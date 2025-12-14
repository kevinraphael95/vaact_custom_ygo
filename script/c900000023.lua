-- Force Attaque sur son Propriétaire
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
		if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
		if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	end)
	e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local tc=Duel.GetFirstTarget()
		if not tc or not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end

		local atk = tc:GetAttack() or 0
		atk = math.floor(atk) -- force entier
		local player = tc:GetControler()
		player = tonumber(player) or 0 -- force entier

		Duel.Damage(player, atk, 1) -- 1 = REASON_EFFECT, entier sûr
		Duel.Hint(HINT_CARD,0,id)
		Duel.Hint(HINT_MESSAGE,tp,"Le monstre attaque son propriétaire !")
	end)
	c:RegisterEffect(e1)
end
