--Double Sort
function c900000019.initial_effect(c)
	-- Target 1 Spell in opponent's GY and use its effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(900000019,0))
	e1:SetCategory(CATEGORY_TOFIELD+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c900000019.target)
	e1:SetOperation(c900000019.activate)
	c:RegisterEffect(e1)
end

function c900000019.filter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToField()
end

function c900000019.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c900000019.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c900000019.filter,tp,0,LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectTarget(tp,c900000019.filter,tp,0,LOCATION_GRAVE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOFIELD,g,1,0,0)
end

function c900000019.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		if Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
			local te=tc:GetActivateEffect()
			local tg=te:GetTarget()
			local op=te:GetOperation()
			if tg then tg(te,tp,eg,ep,ev,re,r,rp,1) end
			if op then op(te,tp,eg,ep,ev,re,r,rp) end
		end
	end
end
