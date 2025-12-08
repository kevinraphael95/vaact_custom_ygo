--Contrôle Cérébral
function c900000006.initial_effect(c)
	--Activate: Pay 800 LP, take control of 1 opponent monster until End Phase
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c900000006.target)
	e1:SetOperation(c900000006.activate)
	c:RegisterEffect(e1)
end

--Filter for face-up opponent monsters
function c900000006.filter(c)
	return c:IsFaceup() and c:IsControlerCanBeChanged()
end

--Targeting
function c900000006.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c900000006.filter(chkc) end
	if chk==0 then return Duel.CheckLPCost(tp,800)
		and Duel.IsExistingTarget(c900000006.filter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.PayLPCost(tp,800)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectTarget(tp,c900000006.filter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end

--Operation: take control until End Phase
function c900000006.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end
