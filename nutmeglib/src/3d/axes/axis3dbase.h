#ifdef SUPPORT_3D
#ifndef AXIS3DBASE_H
#define AXIS3DBASE_H

#include <QQuickItem>

#include "../../common/nutmegobject.h"
#include "../../common/axisspec.h"
#include "../../common/figurebase.h"
#include "../../common/axisbase.h"

class Plot3DBase;
class NUTMEGLIB_EXPORT Axis3DBase : public AxisBase
{
    Q_OBJECT
    Q_PROPERTY(AxisSpec* xAxis READ xAxis NOTIFY xAxisChanged)
    Q_PROPERTY(AxisSpec* yAxis READ yAxis NOTIFY yAxisChanged)
    Q_PROPERTY(AxisSpec* zAxis READ zAxis NOTIFY zAxisChanged)

public:
    explicit Axis3DBase(QQuickItem *parent = 0);

    AxisSpec *xAxis() const;
    AxisSpec *yAxis() const;
    AxisSpec *zAxis() const;

    QString title() const;
    void setTitle(QString title);

    QFont titleFont() const;
    void setTitleFont(QFont titleFont);

    QColor titleColor() const;
    void setTitleColor(QColor titleColor);

signals:
    void xAxisChanged(AxisSpec* xAxis);
    void yAxisChanged(AxisSpec* yAxis);
    void zAxisChanged(AxisSpec* zAxis);

    void titleChanged(QString title);
    void titleFontChanged(QFont titleFont);
    void titleColorChanged(QColor titleColor);

public slots:
private:
    AxisSpec* m_xAxis;
    AxisSpec* m_yAxis;
    AxisSpec* m_zAxis;

    QString m_title;
    QFont m_titleFont;
    QColor m_titleColor;

    QList<Plot3DBase*> m_plots;
};

#endif // AXIS3DBASE_H
#endif
