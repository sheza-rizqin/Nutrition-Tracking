class NutritionGuidance {
  static Map<String, dynamic> getMaternalGuidance(
    int trimester,
    Map<String, dynamic> record,
  ) {
    final hemoglobin = record['hemoglobin'] as double?;
    final folicAcidIntake = record['folic_acid_intake'] as String?;
    final mealCount = record['meal_count'] as int?;
    final dietaryDiversity = record['dietary_diversity'] as String?;
    
    List<String> warnings = [];
    
    // Check for risk factors
    if (hemoglobin != null && hemoglobin < 11.0) {
      warnings.add('Low hemoglobin detected. Increase iron-rich foods and consult healthcare provider.');
    }
    if (folicAcidIntake == 'None' || folicAcidIntake == 'Irregular') {
      warnings.add('Folic acid supplementation is crucial. Please take prescribed supplements daily.');
    }
    if (mealCount != null && mealCount < 3) {
      warnings.add('Increase meal frequency to at least 3-4 meals per day for adequate nutrition.');
    }
    if (dietaryDiversity == 'Poor') {
      warnings.add('Try to include variety: grains, pulses, vegetables, fruits, and dairy daily.');
    }
    
    switch (trimester) {
      case 1:
        return {
          'nutrients': [
            'Folic Acid (400-800 mcg daily)',
            'Iron (27 mg daily)',
            'Calcium (1000 mg daily)',
            'Vitamin B12',
            'Protein (60g daily)',
          ],
          'foods': [
            'Dark leafy greens (spinach, fenugreek)',
            'Lentils and beans',
            'Fortified cereals',
            'Citrus fruits',
            'Milk and dairy products',
            'Eggs and lean meat',
            'Whole grains',
          ],
          'recommendations': [
            'Take folic acid supplements daily',
            'Eat small, frequent meals if experiencing nausea',
            'Stay hydrated - drink 8-10 glasses of water',
            'Avoid raw or undercooked foods',
            'Include vitamin C for better iron absorption',
          ],
          'warnings': warnings,
        };
      
      case 2:
        return {
          'nutrients': [
            'Iron (27 mg daily)',
            'Calcium (1000 mg daily)',
            'Protein (70g daily)',
            'Omega-3 fatty acids (DHA)',
            'Vitamin D',
          ],
          'foods': [
            'Fish (avoid high mercury fish)',
            'Nuts and seeds',
            'Paneer and yogurt',
            'Sweet potatoes',
            'Broccoli and carrots',
            'Whole grain bread and rice',
            'Lean meat and poultry',
          ],
          'recommendations': [
            'Increase protein intake for baby\'s growth',
            'Eat 4-5 small meals throughout the day',
            'Include iron-rich foods with every meal',
            'Get adequate calcium for bone development',
            'Continue prenatal vitamins',
            'Light exercise as recommended by doctor',
          ],
          'warnings': warnings,
        };
      
      case 3:
        return {
          'nutrients': [
            'Iron (27 mg daily)',
            'Calcium (1200 mg daily)',
            'Protein (80-100g daily)',
            'Fiber for digestion',
            'Vitamin K',
          ],
          'foods': [
            'High-protein foods (dal, eggs, chicken)',
            'Calcium-rich dairy products',
            'Fiber-rich vegetables and fruits',
            'Dates and dry fruits',
            'Green vegetables',
            'Whole grains and millets',
            'Healthy fats (ghee, nuts)',
          ],
          'recommendations': [
            'Eat smaller, more frequent meals',
            'Maintain good hydration',
            'Include foods rich in fiber to prevent constipation',
            'Prepare body for labor with nutritious diet',
            'Continue iron and calcium supplements',
            'Avoid excess salt to prevent swelling',
            'Eat energy-dense foods for labor preparation',
          ],
          'warnings': warnings,
        };
      
      default:
        return {
          'nutrients': ['Balanced nutrition required'],
          'foods': ['Variety of food groups'],
          'recommendations': ['Consult with healthcare provider'],
          'warnings': warnings,
        };
    }
  }

  static Map<String, dynamic> getChildGuidance(
    int ageMonths,
    Map<String, dynamic> record,
  ) {
    
    final riskLevel = record['risk_level'] as String?;
    
    List<String> warnings = [];
    
    if (riskLevel == 'High Risk' || riskLevel == 'Severe') {
      warnings.add('Child shows signs of malnutrition. Immediate medical attention required.');
    }
    
    if (ageMonths < 6) {
      return {
        'title': '0-6 Months: Exclusive Breastfeeding',
        'nutrients': [
          'Breast milk provides all necessary nutrients',
        ],
        'foods': [
          'Exclusive breastfeeding',
          'No water or other foods needed',
        ],
        'recommendations': [
          'Feed on demand (8-12 times per day)',
          'Ensure proper latch',
          'Mother should maintain good nutrition',
          'Vitamin D drops as per doctor\'s advice',
        ],
        'warnings': warnings,
      };
    } else if (ageMonths < 12) {
      return {
        'title': '6-12 Months: Complementary Feeding',
        'nutrients': [
          'Iron and zinc from complementary foods',
          'Continued breast milk',
          'Protein for growth',
        ],
        'foods': [
          'Mashed rice and dal',
          'Mashed fruits (banana, apple)',
          'Vegetable purees',
          'Khichdi',
          'Mashed roti with dal',
          'Continue breastfeeding',
        ],
        'recommendations': [
          'Start with 2-3 meals per day',
          'Gradually increase food consistency',
          'Introduce one new food at a time',
          'Continue breastfeeding',
          'Ensure food hygiene',
        ],
        'warnings': warnings,
      };
    } else if (ageMonths < 24) {
      return {
        'title': '12-24 Months: Family Foods',
        'nutrients': [
          'Iron, calcium, protein',
          'Vitamins A and C',
          'Healthy fats for brain development',
        ],
        'foods': [
          'Family foods, well-mashed',
          'Dal, rice, roti',
          'Vegetables and fruits',
          'Eggs, meat, fish',
          'Milk and dairy',
          'Nuts (powdered)',
        ],
        'recommendations': [
          'Offer 3 meals + 2 snacks daily',
          'Include variety of foods',
          'Continue breastfeeding if possible',
          'Let child self-feed',
          'Avoid junk food and sweets',
        ],
        'warnings': warnings,
      };
    } else {
      return {
        'title': '2+ Years: Varied Diet',
        'nutrients': [
          'All food groups',
          'Adequate protein',
          'Iron and calcium',
          'Vitamins and minerals',
        ],
        'foods': [
          'All family foods',
          'Cereals and millets',
          'Pulses and legumes',
          'Vegetables and fruits',
          'Milk and dairy products',
          'Eggs, meat, fish',
        ],
        'recommendations': [
          'Offer 3 meals + 2-3 snacks',
          'Encourage varied diet',
          'Maintain regular meal times',
          'Limit sugary foods and drinks',
          'Ensure adequate water intake',
        ],
        'warnings': warnings,
      };
    }
  }
}
