-- Five Star Twilight (ANIME)
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.activate)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_DUEL)
	c:RegisterEffect(e1)
end

-- Condition : contrôler un monstre Niveau 5 ou plus
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.lv5filter,tp,LOCATION_MZONE,0,1,nil)
end

function s.lv5filter(c)
	return c:IsLevelAbove(5)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,nil)
	if g:GetCount()==0 then return end

	-- Sacrifie tous les monstres que tu contrôles
	Duel.Release(g,REASON_EFFECT)

	-- IDs des Kuribohs
	local ids={900000045,900000046,900000047,900000048,900000049}

	for _,cid in ipairs(ids) do
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then break end

		local token=Duel.CreateToken(tp,cid)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)

		-- Ne peut pas être utilisé pour une Invocation Sacrifice
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UNRELEASABLE_SUM)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1)
	end

	Duel.SpecialSummonComplete()
end
