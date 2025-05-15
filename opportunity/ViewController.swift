import UIKit

struct Plan {
    let title: String
    let price: String
    let subtitle: String
}

class PlanCell: UICollectionViewCell {
    static let identifier = "PlanCell"
    
    private let titleLabel = UILabel()
    private let priceLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = UIColor.secondarySystemBackground
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = false
        contentView.layer.borderWidth = 2
        contentView.layer.borderColor = UIColor.clear.cgColor
        
        priceLabel.font = UIFont.boldSystemFont(ofSize: 24)
        priceLabel.textAlignment = .center
        priceLabel.textColor = .systemBlue
        priceLabel.adjustsFontSizeToFitWidth = true
        priceLabel.minimumScaleFactor = 0.8
        
        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline).withSize(14)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 2
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.8
        
        subtitleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline).withSize(12)
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 2
        subtitleLabel.adjustsFontSizeToFitWidth = true
        subtitleLabel.minimumScaleFactor = 0.8
        
        let stack = UIStackView(arrangedSubviews: [priceLabel, titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(with plan: Plan, selected: Bool) {
        priceLabel.text = plan.price
        titleLabel.text = plan.title
        subtitleLabel.text = plan.subtitle
        contentView.layer.borderColor = selected ? UIColor.systemBlue.cgColor : UIColor.clear.cgColor
        contentView.layer.shadowColor = UIColor.systemBlue.cgColor
        contentView.layer.shadowOpacity = selected ? 0.18 : 0
        contentView.layer.shadowOffset = CGSize(width: 0, height: 8)
        contentView.layer.shadowRadius = selected ? 16 : 0
        contentView.transform = selected ? CGAffineTransform(scaleX: 1.10, y: 1.10) : .identity
        contentView.alpha = selected ? 1.0 : 0.7
    }
}

// floating effect k liye and also for smoother transition keeping size smaller
class CarouselFlowLayout: UICollectionViewFlowLayout {
    let activeDistance: CGFloat = 140
    let zoomFactor: CGFloat = 0.08

    override func prepare() {
        super.prepare()
        scrollDirection = .horizontal
        minimumLineSpacing = 24 // Reduced from 30 for smoother swiping
        sectionInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        itemSize = CGSize(width: 140, height: 160)
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect),
              let collectionView = self.collectionView else { return nil }
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let centerX = visibleRect.midX

        for attr in attributes {
            let distance = abs(attr.center.x - centerX)
            let normalizedDistance = min(distance / activeDistance, 1)
            let zoom = 1 + zoomFactor * (1 - normalizedDistance)
            attr.transform3D = CATransform3DMakeScale(zoom, zoom, 1.0)
            attr.alpha = 1 - normalizedDistance * 0.3 // Reduced alpha change for smoother transition
            attr.zIndex = Int(zoom * 10)
        }
        return attributes
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = self.collectionView else { return proposedContentOffset }

        let proposedRect = CGRect(origin: CGPoint(x: proposedContentOffset.x, y: 0), size: collectionView.bounds.size)
        guard let attributes = super.layoutAttributesForElements(in: proposedRect) else { return proposedContentOffset }

        let centerX = proposedContentOffset.x + collectionView.bounds.width / 2
        var closestAttr: UICollectionViewLayoutAttributes?
        var minDistance: CGFloat = .greatestFiniteMagnitude

        // Adjust snapping based on velocity for smoother feel
        let velocityAdjustment = velocity.x * 100 // Amplify velocity for better snapping
        let adjustedCenterX = centerX + velocityAdjustment

        for attr in attributes {
            let distance = attr.center.x - adjustedCenterX
            if abs(distance) < abs(minDistance) {
                minDistance = distance
                closestAttr = attr
            }
        }

        guard let closest = closestAttr else { return proposedContentOffset }

        var newOffsetX = proposedContentOffset.x + minDistance

        // Soft bounds to prevent over-scrolling
        let maxOffset = collectionView.contentSize.width - collectionView.bounds.width
        newOffsetX = max(0, min(newOffsetX, maxOffset))

        return CGPoint(x: newOffsetX, y: proposedContentOffset.y)
    }
}

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    let plans: [Plan] = [
        Plan(title: "Growth\niOS", price: "$20", subtitle: "Yearly\n$1.67/month"),
        Plan(title: "Pro\niOS", price: "$30", subtitle: "Yearly\n$2.50/month"),
        Plan(title: "Premium\niOS", price: "$40", subtitle: "Yearly\n$3.33/month"),
        Plan(title: "PRO+\niOS", price: "$60", subtitle: "Yearly\n$3.33/month"),
        Plan(title: "Basic\nAll Performance", price: "$4", subtitle: "Monthly"),
        Plan(title: "Growth\niOS", price: "$20", subtitle: "Yearly\n$1.67/month"),
        Plan(title: "Pro\niOS", price: "$30", subtitle: "Yearly\n$2.50/month"),
        Plan(title: "Premium\niOS", price: "$40", subtitle: "Yearly\n$3.33/month"),
        Plan(title: "PRO+\niOS", price: "$60", subtitle: "Yearly\n$3.33/month"),
        Plan(title: "Basic\nAll Performance", price: "$4", subtitle: "Monthly")
    ]
    
    var collectionView: UICollectionView!
    var selectedIndex: Int = 0
    var featureIconViews: [UIImageView] = []
    var continueButtonBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        let titleLabel = UILabel()
        titleLabel.text = "Upgrade Canary Mail"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 28)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        let featureCard = UIView()
        featureCard.backgroundColor = .secondarySystemBackground
        featureCard.layer.cornerRadius = 24
        featureCard.layer.shadowColor = UIColor.black.cgColor
        featureCard.layer.shadowOpacity = 0.08
        featureCard.layer.shadowOffset = CGSize(width: 0, height: 8)
        featureCard.layer.shadowRadius = 16
        featureCard.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(featureCard)
        
        let features: [(String, String, UIColor)] = [
            ("sparkles", "AI Copilot (Summarize , Search)", UIColor.systemBlue),
            ("checkmark", "Read Receipts (Extended History)", UIColor.systemGreen),
            ("paperplane", "Send Later", UIColor.systemBlue),
            ("calendar", "Calendar & Scheduling", UIColor.systemOrange),
            ("wand.and.stars", "Inbox Cleaner", UIColor.systemBlue),
            ("puzzlepiece.extension", "App Integrations", UIColor.label),
            ("slider.horizontal.3", "Advanced Customization", UIColor.systemPink)
        ]
        
        let featureStack = UIStackView()
        featureStack.axis = .vertical
        featureStack.spacing = 18
        featureStack.translatesAutoresizingMaskIntoConstraints = false
        
        for (icon, text, color) in features {
            let hStack = UIStackView()
            hStack.axis = .horizontal
            hStack.spacing = 14
            hStack.alignment = .center
            
            let iconView = UIImageView()
            if let img = UIImage(systemName: icon) {
                iconView.image = img
                iconView.tintColor = color
            }
            iconView.contentMode = .scaleAspectFit
            iconView.translatesAutoresizingMaskIntoConstraints = false
            iconView.widthAnchor.constraint(equalToConstant: 24).isActive = true
            iconView.heightAnchor.constraint(equalToConstant: 24).isActive = true
            featureIconViews.append(iconView)
            
            let label = UILabel()
            label.text = text
            label.textColor = .label
            label.font = UIFont.preferredFont(forTextStyle: .body)
            label.numberOfLines = 2
            
            hStack.addArrangedSubview(iconView)
            hStack.addArrangedSubview(label)
            featureStack.addArrangedSubview(hStack)
            
            // sbhi content ko proper stacking krne k liye (top section content equal spacing)
            hStack.heightAnchor.constraint(greaterThanOrEqualToConstant: 30).isActive = true
            featureStack.addArrangedSubview(hStack)
        }
        featureCard.addSubview(featureStack)

        let layout = CarouselFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 24
        
        layout.sectionInset = UIEdgeInsets(top: 0, left: 36, bottom: 0, right: 36)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = .fast
        collectionView.isPagingEnabled = true // Enabled paging for smoother swiping
        collectionView.clipsToBounds = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PlanCell.self, forCellWithReuseIdentifier: PlanCell.identifier)
        view.addSubview(collectionView)
        
        let continueButton = UIButton(type: .system)
        continueButton.setTitle("Continue", for: .normal)
        continueButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        continueButton.backgroundColor = UIColor.systemBlue
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.layer.cornerRadius = 26
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.layer.shadowColor = UIColor.systemBlue.cgColor
        continueButton.layer.shadowOpacity = 0.18
        continueButton.layer.shadowOffset = CGSize(width: 0, height: 6)
        continueButton.layer.shadowRadius = 12
        view.addSubview(continueButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            featureCard.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 18),
            featureCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            featureCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            featureStack.topAnchor.constraint(equalTo: featureCard.topAnchor, constant: 20),
            featureStack.leadingAnchor.constraint(equalTo: featureCard.leadingAnchor, constant: 20),
            featureStack.trailingAnchor.constraint(equalTo: featureCard.trailingAnchor, constant: -20),
            featureStack.bottomAnchor.constraint(equalTo: featureCard.bottomAnchor, constant: -20),
            
            collectionView.topAnchor.constraint(equalTo: featureCard.bottomAnchor, constant: 36),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 200),
            
            continueButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 24),
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            continueButton.heightAnchor.constraint(equalToConstant: 60), // Increased from 50 to 60
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
        ])
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return plans.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlanCell.identifier, for: indexPath) as! PlanCell
        cell.configure(with: plans[indexPath.item], selected: indexPath.item == selectedIndex)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.item
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        collectionView.reloadData()
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}


