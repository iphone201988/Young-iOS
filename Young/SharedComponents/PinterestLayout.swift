import UIKit

protocol PinterestLayoutDelegate: AnyObject {
    func collectionView(_ collectionView: UICollectionView, layout: PinterestLayout?, heightForItemAt indexPath: IndexPath) -> CGFloat
}

class PinterestLayout: UICollectionViewLayout {
    
    enum Layouts {
        case withContent
        case withoutContent
    }
    
    var layoutType: Layouts = .withoutContent
    private var contentHeight: CGFloat = 0
    
    typealias AttributeCache = [UICollectionViewLayoutAttributes]
    
    // MARK: Delegate
    weak var delegate: PinterestLayoutDelegate?
    
    // MARK: Cache
    private var itemCache: AttributeCache = []
    
    // MARK: Private Variables
    private lazy var contentBounds: CGRect = {
        guard let collectionView = collectionView else { return .zero }
        let size = collectionView.bounds.inset(by: collectionView.contentInset).size
        return CGRect(origin: .zero, size: size)
    }()
    
    // MARK: Public Variables
    var cellPadding: CGFloat = 6 {
        didSet {
            if oldValue != cellPadding { invalidateLayout() }
        }
    }
    
    var numberOfColumns = 2 {
        didSet {
            if oldValue != numberOfColumns { invalidateLayout() }
        }
    }
    
    var cellWidth: CGFloat {
        switch layoutType {
        case .withContent:
            return (contentBounds.width / CGFloat(numberOfColumns)) - 2 * cellPadding
        case .withoutContent:
            return collectionView?.bounds.width ?? 0
        }
    }
    
    // MARK: - Overrides
    override func prepare() {
        
        switch layoutType {
        case .withContent:
            guard let collectionView = collectionView else { return }
            itemCache.removeAll()
            
            var xOffsets: [CGFloat] = .init(repeating: 0, count: numberOfColumns)
            xOffsets = xOffsets.indices.map { CGFloat($0) * contentBounds.width / CGFloat(numberOfColumns) }
            
            var yOffsets: [CGFloat] = .init(repeating: 0, count: numberOfColumns)
            
            let count = collectionView.numberOfItems(inSection: 0)
            
            var column = 0
            var itemIndex = 0
            
            while itemIndex < count {
                let indexPath = IndexPath(item: itemIndex, section: 0)
                
                let photoHeight = delegate?.collectionView(collectionView, layout: self,
                                                           heightForItemAt: indexPath) ?? 180
                let height = cellPadding * 2 + photoHeight
                let width = contentBounds.width / CGFloat(numberOfColumns)
                let frame = CGRect(x: xOffsets[column],
                                   y: yOffsets[column],
                                   width: width,
                                   height: height)
                
                let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = insetFrame
                itemCache.append(attributes)
                contentBounds = contentBounds.union(frame)
                yOffsets[column] = frame.maxY
                column = yOffsets.indexOfMin ?? 0 // Waterfall Layout
                itemIndex += 1
            }
            
        case .withoutContent:
            guard itemCache.isEmpty, let collectionView = collectionView else { return }
            
            let columnWidth = (cellWidth - (CGFloat(numberOfColumns + 1) * cellPadding)) / CGFloat(numberOfColumns)
            var xOffset: [CGFloat] = []
            for column in 0..<numberOfColumns {
                xOffset.append(CGFloat(column) * (columnWidth + cellPadding) + cellPadding)
            }
            
            var columnHeights: [CGFloat] = Array(repeating: cellPadding, count: numberOfColumns)
            
            for item in 0..<collectionView.numberOfItems(inSection: 0) {
                let indexPath = IndexPath(item: item, section: 0)
                let column = columnHeights[0] <= columnHeights[1] ? 0 : 1
                
                let itemHeight = delegate?.collectionView(collectionView, layout: self, heightForItemAt: indexPath) ?? 140
                let height = itemHeight + cellPadding
                
                let frame = CGRect(x: xOffset[column],
                                   y: columnHeights[column],
                                   width: columnWidth,
                                   height: itemHeight)
                
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = frame
                itemCache.append(attributes)
                
                columnHeights[column] += height
                contentHeight = max(contentHeight, columnHeights[column])
            }
        }
    }
    
    override var collectionViewContentSize: CGSize {
        return contentBounds.size
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = collectionView else { return false }
        return !newBounds.size.equalTo(collectionView.bounds.size)
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        switch layoutType {
        case .withContent:
            return itemCache[indexPath.item]
        case .withoutContent:
            return itemCache.first { $0.indexPath == indexPath }
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        switch layoutType {
        case .withContent:
            var result = [UICollectionViewLayoutAttributes]()
            let attributes = binSearchAttributes(in: itemCache, intersecting: rect)
            result.append(contentsOf: attributes)
            return result
        case .withoutContent:
            return itemCache.filter { $0.frame.intersects(rect) }
        }
    }
    
    // MARK: - Helpers
    func binSearchAttributes(in cache: AttributeCache, intersecting rect: CGRect) -> AttributeCache {
        var result = [UICollectionViewLayoutAttributes]()
        
        let start = cache.startIndex
        guard let end = cache.indices.last else { return result }
        
        guard let firstMatchIndex = findPivot(in: cache, for: rect, start: start, end: end) else {
            return result
        }
        
        for attributes in cache[..<firstMatchIndex].reversed() {
            guard attributes.frame.maxY >= rect.minY else { break }
            result.append(attributes)
        }
        
        for attributes in cache[firstMatchIndex...] {
            guard attributes.frame.minY <= rect.maxY else { break }
            result.append(attributes)
        }
        
        return result
    }
    
    func findPivot(in cache: AttributeCache, for rect: CGRect, start: Int, end: Int) -> Int? {
        if end < start { return nil }
        
        let mid = (start + end) / 2
        let attr = cache[mid]
        
        if attr.frame.intersects(rect) {
            return mid
        } else {
            if attr.frame.maxY < rect.minY {
                return findPivot(in: cache, for: rect, start: (mid + 1), end: end)
            } else {
                return findPivot(in: cache, for: rect, start: start, end: (mid - 1))
            }
        }
    }
}

extension Dictionary where Value: RangeReplaceableCollection {
    mutating func updateCollection(keyedBy key: Key, with element: Value.Element) {
        if var collection = self[key] {
            collection.append(element)
            self[key] = collection
        } else {
            var collection = Value()
            collection.append(element)
            self[key] = collection
        }
    }
}

extension Array where Element: Comparable {
    var indexOfMin: Int? {
        guard let min = self.min() else { return nil }
        return self.firstIndex(of: min)
    }
}

extension String {
    func heightFitting(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [.font: font], context: nil)
        return boundingBox.height
    }
}
