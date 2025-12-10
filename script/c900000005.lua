-- Slifer, le Dragon Céleste
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()

	-- Nécessite EXACTEMENT 3 Sacrifices pour être invoqué
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e0:SetCondition(s.sumcon)
	e0:SetOperation(s.sumop)
	c:RegisterEffect(e0)
	local e0b=e0:Clone()
	e0b:SetCode(EFFECT_LIMIT_SET_PROC)
	c:RegisterEffect(e0b)

	-- Ne peut pas être sacrifié
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UNRELEASABLE_SUM)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e1b=e1:Clone()
	e1b:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e1b)

	-- Contrôle ne peut pas changer
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
	c:RegisterEffect(e2)

	-- Immunité Magies/Pièges qui la feraient quitter le Terrain
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetValue(s.stimmune)
	c:RegisterEffect(e3)

	-- Immunité aux effets de monstres sauf DIVINE
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetValue(s.monimmune)
	c:RegisterEffect(e4)

	-- Effets des autres cartes durent 1 tour
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_CHAIN_SOLVED)
	e5:SetRange(LOCATION_MZONE)
	e5:SetOperation(s.limiteff)
	c:RegisterEffect(e5)

	-- +1000 ATK/DEF par carte en main
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_UPDATE_ATTACK)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetValue(s.atkval)
	c:RegisterEffect(e6)
	local e6b=e6:Clone()
	e6b:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e6b)

	-- Monstres adverses en ATK perdent 2000 ATK
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e7:SetCode(EVENT_SUMMON_SUCCESS)
	e7:SetRange(LOCATION_MZONE)
	e7:SetOperation(s.atkop)
	c:RegisterEffect(e7)
	local e7b=e7:Clone()
	e7b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e7b)

	-- Envoyé au GY End Phase si Invoqué Spécialement
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e8:SetCode(EVENT_PHASE+PHASE_END)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCountLimit(1)
	e8:SetCondition(s.gycon)
	e8:SetOperation(s.gyop)
	c:RegisterEffect(e8)
end

-- Procédure invoc exacte 3 tributs
function s.sumfilter(c)
	return c:IsReleasable()
end
function s.sumcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>-3 
		and Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_MZONE,0,3,nil)
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_MZONE,0,3,3,nil)
	c:SetMaterial(g)
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end

-- Immunités
function s.stimmune(e,te)
	if not te:IsActiveType(TYPE_SPELL+TYPE_TRAP) then return false end
	return te:IsHasCategory(CATEGORY_REMOVE)
		or te:IsHasCategory(CATEGORY_TOHAND)
		or te:IsHasCategory(CATEGORY_TODECK)
		or te:IsHasCategory(CATEGORY_TOGRAVE)
		or te:IsHasCategory(CATEGORY_RELEASE)
end
function s.monimmune(e,te)
	return te:IsActiveType(TYPE_MONSTER) and not te:GetHandler():IsRace(RACE_DIVINE)
end

-- Autres effets durent 1 tour
function s.limiteff(e,tp,eg,ep,ev,re,r,rp)
	if re and re:GetHandler()~=e:GetHandler() then
		re:SetReset(RESET_PHASE+PHASE_END)
	end
end

-- End Phase si Invoc Spé
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoGrave(e:GetHandler(),REASON_RULE)
end

-- ATK/DEF = cartes en main x1000
function s.atkval(e,c)
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_HAND,0)*1000
end

-- -2000 ATK aux monstres adverses en ATK
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(Card.IsControler,nil,1-tp)
	for tc in aux.Next(g) do
		if tc:IsPosition(POS_FACEUP_ATTACK) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-2000)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			if tc:GetAttack()==0 then
				Duel.Destroy(tc,REASON_EFFECT)
			end
		end
	end
end
