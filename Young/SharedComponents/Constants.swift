import Foundation

struct AppColors {
    static let appColorLight = "appColorLight"
    static let appColor = "appColor"
}

struct CurrentLocation {
    static var latitude = 0.0
    static var longitude = 0.0
}

struct Constants {
    
    static var deviceType = 1
    
    static var accountRegistrationFor: Events = .unspecified
    
    static var ageRanges = ["18-21", "22-25", "26-35", "35-50", "50-65", ">65"]
    
    static var genders = ["Male", "Female", "Nonbinary", "Other"]
    
    static var martialStatus = ["Single", "In a relationship", "Married", "Divorced", "Widowed"]
    
    static var children = ["0", "planning", "1", "2...10", ">10"]
    
    static var homeOwnershipStatus = ["Rent", "Own", "Other"]
    
    static var generalMemberObjective = ["Find a professional", "Financial literacy", "Networking"]
    
    static var generalMemberFinancialExperience = ["Limited", "Moderate", "Extensive"]
    
    static var generalMemberInvestments = ["Stocks",
                                           "Retirement",
                                           "Cryptocurrency",
                                           "Real Estate",
                                           "Startups",
                                           "Savings"]
    
    static var generalMemberServicesInterested = ["Financial planning",
                                                  "Investment management",
                                                  "Child education",
                                                  "Estate planning",
                                                  "Student loan management",
                                                  "Debt management",
                                                  "Startups",
                                                  "Small businesses",
                                                  "Life Insurance"]
    
    static var financialAdvisorProductsServicesOffered = ["Financial planning",
                                                          "Investment management",
                                                          "Child education",
                                                          "Estate planning",
                                                          "Student loan management",
                                                          "Debt management",
                                                          "Startups",
                                                          "Small businesses",
                                                          "Life Insurance"]
    
    static var financialAdvisorAreasOfExpertise = ["Financial planning",
                                                   "Investment management",
                                                   "Child education",
                                                   "Estate planning",
                                                   "Student loan management",
                                                   "Debt management",
                                                   "Startups",
                                                   "Small businesses",
                                                   "Life Insurance"]
    
    static var startupAndSmallBusinessIndustry = ["Technology",
                                                  "Healthcare",
                                                  "E-commerce",
                                                  "Retail",
                                                  "Biotech",
                                                  "Fintech",
                                                  "Education",
                                                  "Other"]
    
    static var startupAndSmallBusinessInterestedIn = ["Investors",
                                                      "Loans",
                                                      "Donations",
                                                      "Customers",
                                                      "Hiring"]
    
    static var investorVCIndustryInterestedIn = ["Technology",
                                                 "Healthcare",
                                                 "E-commerce",
                                                 "Retail",
                                                 "Biotech",
                                                 "Fintech",
                                                 "Education",
                                                 "Other"]
    
    static var investorVCAreasOfExpertise = ["Investment analysis",
                                             "Financial modeling",
                                             "Mentorship",
                                             "Distribution chain",
                                             "Industry knowledge",
                                             "Industry connections"]
    
    static var insuranceProductsServicesOffered = ["Insurance", "Annuities", "Other"]
    
    static var  insuranceAreasOfExpertise = ["Insurance", "Annuities", "Other"]
    
    static var race = ["Black",
                       "White",
                       "Asian",
                       "Hispanic/ Latino",
                       "American Indian/ Alaska Native",
                       "Native Hawaiian/ Pacific Islander"]
    
    static var educationLevel = ["High school", "College", "Graduate school"]
    
    static var yearsEmployed = ["0-5", "6-10", "10-20", ">20"]
    
    static var yearsInFinancialIndustry = ["0-3", "4-10", "10+"]
    
    static var salaryRange = ["Unemployed", "$0-10K", "$11-50K", "$51-100K", "$101-200K", "$201-250K", "over $251K"]
    
    static var financialExperience = ["Limited", "Moderate", "Extensive"]
    
    static var riskTolerance = ["Low - Risks scare me", "Moderate - I’m on the fence", "High - Bring it on"]
    
    static var feedTopics = ["Stocks",
                             "Crypto",
                             "Insurance",
                             "Retirement",
                             "Savings",
                             "Investment Management",
                             "Child Education",
                             "Student Loan Management",
                             "Debt Management",
                             "Tax Planning",
                             "Financial Planning",
                             "Wealth Education",
                             "Estate Planning",
                             "Investor",
                             "Venture Capitalist",
                             "Small Business",
                             "Grants",
                             "Loans",
                             "Insurance",
                             "Annuities"]
    
    static var topicsOfInterest = ["Wealth Education",
                                   "Household budgeting",
                                   "Financial planning",
                                   "Wealth Management",
                                   "Investing",
                                   "Child Education Planning",
                                   "Retirement Planning",
                                   "Estate Planning",
                                   "Debt Management",
                                   "Student loan Management",
                                   "Tax Planning",
                                   "Annuities",
                                   "Life Insurance",
                                   "Stocks",
                                   "Index funds",
                                   "ETFs",
                                   "Bonds",
                                   "Mutual Funds",
                                   "Crypto",
                                   "REITs",
                                   "Tech",
                                   "Conservative funds",
                                   "Moderate funds",
                                   "Aggressive funds",
                                   "Startups (Tech, Health, Lifestyle, Education, Ecommerce, Other)"]
    
    static var licensesOrCertification = ["Securities", "CFA", "Other"]
    
    static var adsPlan = ["$250 for 1 month", "$500 for 6 month", "$1000 for Lifetime"]
    
    static var servicesOffered = ["Wealth Education",
                                  "Household budgeting",
                                  "Financial planning",
                                  "Wealth Management",
                                  "Investing",
                                  "Child Education Planning",
                                  "Retirement Planning",
                                  "Estate Planning",
                                  "Debt Management",
                                  "Student loan Management",
                                  "Tax Planning"]
    
    static var stageOfBusiness = ["Pre-Seed", "Seed", "Series A", "Series B"]
    
    static var fundsRaised = ["$10K-$100K", "$100K-$1M", "$1M-$3M", "$3M-$15M", ">$15M"]
    
    static var fundsRaising = ["$50K-$250K", "$500K-$2M", "$2M-$5M", "$5M-$20M", ">$20M"]
    
    static var businessRevenue = ["$0-$50K", "$50K-$500K", "$500K-$5M", "$5M-$25M", ">$25M"]
    
    static var startUpSeeking = ["Investors (VC, angel, private)",
                                 "Loans",
                                 "Donations",
                                 "Customers",
                                 "Hiring"]
    
    static var productsOrServicesOffered = ["Annuities",
                                            "Whole life Insurance",
                                            "Universal Life Insurance",
                                            "Index Life Insurance",
                                            "Term Life Insurance",
                                            "Variable Life Insurance",
                                            "Group Life Insurance",
                                            "Other"]
    
    static var reportReasons = ["Spam",
                                "Harassment",
                                "Hate Speech",
                                "Violence or Threats",
                                "Sexually Explicit Content",
                                "Child Exploitation",
                                "Self-Harm or Suicide",
                                "False Information",
                                "Scam or Fraud",
                                "Impersonation",
                                "Inappropriate Username or Profile",
                                "Intellectual Property Violation",
                                "Privacy Violation",
                                "Terrorism or Extremism",
                                "Illegal Activity",
                                "Disruptive Behavior",
                                "Wrong Category",
    ]
    
    
    //    static var insuranceAreasOfExpertise = ["Wealth Education",
    //                                            "Household budgeting",
    //                                            "Financial planning",
    //                                            "Wealth Management",
    //                                            "Investing",
    //                                            "Child Education Planning",
    //                                            "Retirement Planning",
    //                                            "Estate Planning",
    //                                            "Debt Management",
    //                                            "Student loan Management",
    //                                            "Tax Planning",
    //                                            "Annuities",
    //                                            "Life Insurance",
    //                                            "Stocks",
    //                                            "Index funds",
    //                                            "ETFs",
    //                                            "Bonds",
    //                                            "Mutual Funds",
    //                                            "Crypto",
    //                                            "REITs",
    //                                            "Tech",
    //                                            "Conservative funds",
    //                                            "Moderate funds",
    //                                            "Aggressive funds"]
    
    
}
