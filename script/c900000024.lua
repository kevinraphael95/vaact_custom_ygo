--Dé-Fusion
function c900000024.initial_effect(c)
	-- Activate: return Fusion Monster to Extra Deck, special summon its materials
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(900000024,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c900000024.target)
	e1:SetOperation(c900000024.activate)
	c:RegisterEffect(e1)
end

function c900000024.filter(c)
	return c:IsType(TYPE_FUSION) and c:IsAbleToExtra()
end

function c900000024.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c900000024.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c900000024.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,c900000024.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end

function c900000024.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	local mats=tc:GetMaterial()
	if Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)~=0 then
		if mats and #mats>0 then
			local canSummon=true
			for _,mc in ipairs(mats) do
				if not mc:IsLocation(LOCATION_GRAVE) then
					canSummon=false
					break
				end
			end
			if canSummon and Duel.GetLocationCount(tp,LOCATION_MZONE)>=#mats then
				for _,mc in ipairs(mats) do
					Duel.SpecialSummonStep(mc,0,tp,tp,false,false,POS_FACEUP)
				end
				Duel.SpecialSummonComplete()
			end
		end
	end
end
