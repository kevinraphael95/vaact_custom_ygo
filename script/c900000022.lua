--Excalibur
function c900000022.initial_effect(c)
	-- Equip procedure
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(aux.TRUE)
	c:RegisterEffect(e1)
	
	-- Double equipped monster's original ATK
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_SET_ATTACK_FINAL)
	e2:SetValue(function(e,c) return c:GetBaseAttack()*2 end)
	c:RegisterEffect(e2)
	
	-- Skip Draw Phase
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SKIP_DP)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	c:RegisterEffect(e3)
	
	-- Destroy this card if you draw
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetCode(EVENT_DRAW)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(c900000022.descon)
	e4:SetOperation(c900000022.desop)
	c:RegisterEffect(e4)
end

function c900000022.descon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end

function c900000022.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.Destroy(c,REASON_EFFECT)
	end
end
