-- Contrôle Cérébral
local s,id=GetID()
function s.initial_effect(c)
	-------------------------------------
	-- Activation : payez 800 LP, prenez le contrôle d'1 monstre adversaire jusqu'à la End Phase
	-------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

-------------------------------------
-- Filtre pour monstre face recto que l'on peut prendre
-------------------------------------
function s.filter(c)
	return c:IsFaceup() and c:IsControlerCanBeChanged()
end

-------------------------------------
-- Target pour l'activation
-------------------------------------
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then 
		return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) 
	end
	if chk==0 then 
		return Duel.CheckLPCost(tp,800)
			and Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil) 
	end
	Duel.PayLPCost(tp,800)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end

-------------------------------------
-- Opération : prendre le contrôle du monstre jusqu'à la End Phase
-------------------------------------
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end
