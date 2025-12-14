--Kuriboh (Ext. Duel)
local s,id=GetID()
function s.initial_effect(c)
	-- Cannot be in Main Deck at start of duel
	c:SetUniqueOnField(1,0,id)
	
	-- Effect 1: Negate battle damage by discarding
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.damcon)
	e1:SetCost(s.damcost)
	e1:SetOperation(s.damop)
	c:RegisterEffect(e1)
	
	-- Effect 2: Negate effect targeting this card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.negcon)
	e2:SetCost(s.damcost)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
end

-- Effect 1: Condition to negate battle damage
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end

-- Effect 1: Cost is to discard this card
function s.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end

-- Effect 1: Operation to negate battle damage
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateBattleDamage(tp)
end

-- Effect 2: Condition to negate an effect targeting this card
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- Vérifie que l'effet cible une carte et que la cible est ce Kuriboh
	return re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and re:GetHandler():IsOnField()
		and Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS):IsContains(c)
end

-- Effect 2: Target setup (necessary for chaining)
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end

-- Effect 2: Negate the activation
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateActivation(ev)
end
