--Kuriboh (Ext. Duel)
function c900000018.initial_effect(c)
	-- Cannot be in Main Deck at start of duel
	c:SetUniqueOnField(1,0,900000018)
	
	-- Effect 1: Negate battle damage by discarding
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c900000018.damcon)
	e1:SetCost(c900000018.damcost)
	e1:SetOperation(c900000018.damop)
	c:RegisterEffect(e1)
	
	-- Effect 2: Negate attack/effect targeting this card
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c900000018.negcon)
	e2:SetCost(c900000018.damcost)
	e2:SetTarget(c900000018.negtg)
	e2:SetOperation(c900000018.negop)
	c:RegisterEffect(e2)
end

-- Condition for battle damage
function c900000018.damcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end

-- Cost: discard this card
function c900000018.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end

-- Operation: take no battle damage
function c900000018.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateBattleDamage(tp)
end

-- Condition for negating effect targeting this card
function c900000018.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and re:GetHandler():IsOnField()
		and Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS):IsContains(c)
end

function c900000018.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end

function c900000018.negop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateActivation(ev)
end
