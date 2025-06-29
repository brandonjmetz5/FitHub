// functions/index.js
// Firebase Cloud Functions for FitHub Badges

const functions = require('firebase-functions/v1');
const { onSchedule } = require('firebase-functions/v2/scheduler');
const admin = require('firebase-admin');
admin.initializeApp();

// Badge thresholds
const thresholds = {
  proteinWarrior:    { bronze: 5,  silver: 10, gold: 15, elite: 20, platinum: 25 },
  carbConqueror:     { bronze: 5,  silver: 10, gold: 15, elite: 20, platinum: 25 },
  fatFighter:        { bronze: 5,  silver: 10, gold: 15, elite: 20, platinum: 25 },
  calorieCommander:  { bronze: 5,  silver: 10, gold: 15, elite: 20, platinum: 25 },
  macroMaestro:      { bronze: 3,  silver: 7,  gold: 10, elite: 15, platinum: 20 },
  dailyLogger:       { bronze: 5,  silver: 10, gold: 15, elite: 20, platinum: 25 },
  mealMaestro:       { bronze: 3,  silver: 7,  gold: 10, elite: 15, platinum: 20 },
  monthlyMarathoner: { bronze: 10, silver: 15, gold: 20, elite: 25,
                       platinum: () => new Date(new Date().getFullYear(), new Date().getMonth() + 1, 0).getDate() },
  streakMaster:      { bronze: 3,  silver: 7,  gold: 14, elite: 21, platinum: 28 },
  workoutInitiate:   { bronze: 5,  silver: 10, gold: 15, elite: 20, platinum: 25 },
  strengthBuilder:   { bronze: 5,  silver: 10, gold: 15, elite: 20, platinum: 25 },
  cardioChamp:       { bronze: 5,  silver: 10, gold: 15, elite: 20, platinum: 25 },
  weighInEnthusiast: { bronze: 5,  silver: 10, gold: 15, elite: 20, platinum: 25 },
  scaleSurpasser:    { bronze: 3,  silver: 7,  gold: 14, elite: 21, platinum: 28 },
  bigGains:          { bronze: 3,  silver: 7,  gold: 14, elite: 21, platinum: 28 },
  weightConsistency: { bronze: 1,  silver: 2,  gold: 3,  elite: 4,  platinum: 5 },
  badgeCollector:    { bronze: 4,  silver: 8,  gold: 12, elite: 16, platinum: 18 },
  masterOfMetrics:   { gold: 15,  elite: 15, platinum: 15 }
};

async function computeBadgeCounts(uid) {
  const db = admin.firestore();
  const now = new Date();
  const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);

  const userDoc = await db.doc(`users/${uid}`).get();
  const user = userDoc.data() || {};
  const proteinTarget = user.proteinTarget || 0;
  const fatTarget = user.fatTarget || 0;
  const carbsTarget = user.carbsTarget || 0;
  const calorieTarget = user.dailyCalorieAllowance || 0;

  const meta = await db.doc(`users/${uid}/meta/profile`).get();
  const goal = meta.exists ? meta.data().goal : 'Maintain Weight';

  // Food logs
  const foodLogs = await db.collection(`users/${uid}/foodLogs`).listDocuments();
  let proteinWarrior = 0, fatFighter = 0, carbConqueror = 0, calorieCommander = 0, macroMaestro = 0;
  let mealSet = new Set();
  let foodDays = new Set();

  for (const dateRef of foodLogs) {
    const entriesSnap = await db.collection(`${dateRef.path}/entries`).get();
    let dayProtein = 0, dayCarbs = 0, dayFats = 0, dayCalories = 0;
    let meetsProtein = false, meetsCarbs = false, meetsFats = false;
    let logged = false;

    for (const entry of entriesSnap.docs) {
      const e = entry.data();
      const loggedAt = e.loggedAt?.toDate?.();
      if (!loggedAt || loggedAt < startOfMonth) continue;

      logged = true;
      dayProtein += e.protein || 0;
      dayCarbs += e.carbs || 0;
      dayFats += e.fat || 0;
      dayCalories += e.calories || 0;
      mealSet.add(e.meal);
    }

    if (logged) foodDays.add(dateRef.id);

    if (dayProtein >= proteinTarget) { proteinWarrior++; meetsProtein = true; }
    if (dayCarbs <= carbsTarget) { carbConqueror++; meetsCarbs = true; }
    if (dayFats <= fatTarget) { fatFighter++; meetsFats = true; }

    if (
      (goal === 'Lose Weight' && dayCalories < calorieTarget) ||
      (goal === 'Gain Weight' && dayCalories > calorieTarget) ||
      (goal === 'Maintain Weight' && Math.abs(dayCalories - calorieTarget) <= 100)
    ) {
      calorieCommander++;
    }

    if (meetsProtein && meetsCarbs && meetsFats) {
      macroMaestro++;
    }
  }

  // Workout logs
  const workoutSnapshot = await db.collection(`users/${uid}/workoutLogs`).get();
  let workoutInitiate = 0, strengthBuilder = 0, cardioChamp = 0;
  let workoutDays = new Set();

  for (const doc of workoutSnapshot.docs) {
    const data = doc.data();
    const loggedAt = (data.loggedAt || data.date)?.toDate?.();
    if (!loggedAt || loggedAt < startOfMonth) continue;

    workoutInitiate++;
    const dateStr = loggedAt.toISOString().slice(0, 10);
    workoutDays.add(dateStr);

    const types = new Set(
      (data.performedExercises || []).map(e => e.exercise?.inputType?.toLowerCase())
    );
    if (types.has('strength')) strengthBuilder++;
    if (types.has('cardio')) cardioChamp++;
  }

  // Weight logs
  const weightSnap = await db.collection(`users/${uid}/weightLogs`).get();
  const weightLogs = weightSnap.docs
    .map(doc => doc.data())
    .filter(d => (d.loggedAt || d.date)?.toDate?.() >= startOfMonth)
    .sort((a, b) =>
      (a.loggedAt || a.date).toDate() - (b.loggedAt || b.date).toDate()
    );

  let weighInDays = new Set();
  let scaleSurpasser = 0, bigGains = 0, weightConsistency = 0;

  for (let i = 1; i < weightLogs.length; i++) {
    const prev = weightLogs[i - 1].weight;
    const curr = weightLogs[i].weight;
    if (curr < prev) scaleSurpasser++;
    else if (curr > prev) bigGains++;
    else if (Math.abs(curr - prev) <= 0.25) weightConsistency++;
  }

  for (const w of weightLogs) {
    const dateStr = (w.loggedAt || w.date)?.toDate?.().toISOString().slice(0, 10);
    if (dateStr) weighInDays.add(dateStr);
  }

  // streakMaster
  let streak = 0;
  let maxStreak = 0;
  const iter = new Date(startOfMonth);

  while (iter <= now) {
    const dayStr = iter.toISOString().slice(0, 10);
    if (
      workoutDays.has(dayStr) &&
      foodDays.has(dayStr) &&
      weighInDays.has(dayStr)
    ) {
      streak++;
      maxStreak = Math.max(maxStreak, streak);
    } else {
      streak = 0;
    }
    iter.setDate(iter.getDate() + 1);
  }

  // badgeCollector
  const badgesSnap = await db.collection(`users/${uid}/badges`).get();
  const badgeCollector = badgesSnap.docs.filter(doc => {
    const tier = doc.data().tier;
    return tier && tier !== 'none';
  }).length;

  // masterOfMetrics
  const tierCounts = { bronzeCount: 0, silverCount: 0, goldCount: 0 };
  for (const doc of badgesSnap.docs) {
    const tier = doc.data().tier;
    if (tier === 'bronze') tierCounts.bronzeCount++;
    if (tier === 'silver') tierCounts.silverCount++;
    if (tier === 'gold') tierCounts.goldCount++;
  }

  return {
    proteinWarrior,
    fatFighter,
    carbConqueror,
    calorieCommander,
    macroMaestro,
    mealMaestro: mealSet.size,
    workoutInitiate,
    strengthBuilder,
    cardioChamp,
    dailyLogger: workoutDays.size,
    monthlyMarathoner: 0,
    streakMaster: maxStreak,
    weighInEnthusiast: weighInDays.size,
    scaleSurpasser,
    bigGains,
    weightConsistency,
    badgeCollector,
    masterOfMetrics: tierCounts
  };
}

async function recalculateBadges(uid) {
  const db = admin.firestore();
  const counts = await computeBadgeCounts(uid);
  const batch = db.batch();

  for (const [badgeType, thresh] of Object.entries(thresholds)) {
    let newTier = 'none';
    const current = badgeType === 'masterOfMetrics'
      ? counts.masterOfMetrics.goldCount
      : counts[badgeType];

    for (const tier of ['platinum', 'elite', 'gold', 'silver', 'bronze']) {
      const goal = typeof thresh[tier] === 'function' ? thresh[tier]() : thresh[tier];
      if (current >= goal) {
        newTier = tier;
        break;
      }
    }

    const ref = db.doc(`users/${uid}/badges/${badgeType}`);
    const snap = await ref.get();
    const existing = snap.exists ? snap.data() : {};

    const previousTier = existing.tier || 'none';
    const earnedMap = existing.timesEarnedByTier || {};
    const updatedMap = { ...earnedMap };

    if (previousTier !== newTier) {
      if (previousTier !== 'none') {
        updatedMap[previousTier] = Math.max((updatedMap[previousTier] || 1) - 1, 0);
      }
      if (newTier !== 'none') {
        updatedMap[newTier] = (updatedMap[newTier] || 0) + 1;
      }
    }

    batch.set(ref, {
      type: badgeType,
      tier: newTier,
      lastAwarded: admin.firestore.FieldValue.serverTimestamp(),
      timesEarnedByTier: updatedMap
    }, { merge: true });
  }

  await batch.commit();
}

// Triggers
exports.onFoodLogWrite = functions.firestore
  .document('users/{uid}/foodLogs/{date}/entries/{entryId}')
  .onWrite((change, context) => recalculateBadges(context.params.uid));

exports.onWeightLogWrite = functions.firestore
  .document('users/{uid}/weightLogs/{docId}')
  .onWrite((change, context) => recalculateBadges(context.params.uid));

exports.onWorkoutLogWrite = functions.firestore
  .document('users/{uid}/workoutLogs/{docId}')
  .onWrite((change, context) => recalculateBadges(context.params.uid));

// Monthly reset
exports.monthlyBadgeReset = onSchedule('0 0 1 * *', { timeZone: 'UTC' }, async () => {
  const db = admin.firestore();
  const users = await db.collection('users').listDocuments();
  const batch = db.batch();

  for (const user of users) {
    const badges = await user.collection('badges').listDocuments();
    for (const b of badges) {
      batch.update(b, { tier: 'none' });
    }
  }

  return batch.commit();
});
